`timescale 1ns/1ps
`include "defines.v"

module cpu_if
#(
   parameter UDP_REG_SRC_WIDTH = 2
)
(
   // Register ring interface
   input                               reg_req_in,
   input                               reg_ack_in,
   input                               reg_rd_wr_L_in,
   input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
   input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
   input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

   output                              reg_req_out,
   output                              reg_ack_out,
   output                              reg_rd_wr_L_out,
   output [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_out,
   output [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_out,
   output [UDP_REG_SRC_WIDTH-1:0]      reg_src_out,

   input                               clk,
   input                               reset
);

   // =====================================================
   // Software-visible registers (via generic_regs)
   // =====================================================

   wire [31:0] cpu_cmd;
   wire [31:0] cpu_addr;
   wire [31:0] cpu_wdata;
   reg  [31:0] cpu_rdata;

   generic_regs
   #(
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .TAG               (`CPU_BLOCK_ADDR),
      .REG_ADDR_WIDTH    (`CPU_REG_ADDR_WIDTH),
      .NUM_COUNTERS      (0),
      .NUM_SOFTWARE_REGS (3),   // cmd, addr, wdata
      .NUM_HARDWARE_REGS (1)    // rdata
   )
   cpu_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      .counter_updates  (),
      .counter_decrement(),

      .software_regs    ({cpu_wdata, cpu_addr, cpu_cmd}),
      .hardware_regs    (cpu_rdata),

      .clk              (clk),
      .reset            (reset)
   );

   // =====================================================
   // Command decode
   // =====================================================

   wire write_en   = cpu_cmd[0];
   wire read_en    = cpu_cmd[1];
   wire cpu_enable = cpu_cmd[2];

   // =====================================================
   // Instruction Memory (single-port)
   // =====================================================

   wire [`INSTR_WIDTH-1:0] i_mem_dout;
   reg  [`INSTR_WIDTH-1:0] i_mem_din;
   reg  [`I_MEM_ADDR_WIDTH-1:0] i_mem_addr;
   reg  i_mem_we;
   reg  i_mem_en;

   i_mem_core u_imem (
      .clka  (clk),
      .dina  (i_mem_din),
      .addra (i_mem_addr),
      .ena   (i_mem_en),
      .wea   ({i_mem_we}),
      .douta (i_mem_dout)
   );

   // =====================================================
   // Data Memory (simple dual-port)
   //   Port A: Read/Write
   //   Port B: Read-only
   // =====================================================

   wire [`DATA_WIDTH-1:0] d_mem_doutb;

   reg  [`DATA_WIDTH-1:0] d_mem_dina;
   reg  [`D_MEM_ADDR_WIDTH-1:0] d_mem_addra;
   reg  [`D_MEM_ADDR_WIDTH-1:0] d_mem_addrb;

   reg  d_mem_wea;
   reg  d_mem_ena;
   reg  d_mem_enb;

   d_mem_core u_dmem (
      .clka  (clk),
      .dina  (d_mem_dina),
      .addra (d_mem_addra),
      .ena   (d_mem_ena),
      .wea   ({d_mem_wea}),

      .clkb  (clk),
      .addrb (d_mem_addrb),
      .enb   (d_mem_enb),
      .doutb (d_mem_doutb)
   );

   // =====================================================
   // CPU datapath
   // =====================================================

   wire [`PC_WIDTH-1:0]          cpu_i_addr;
   wire [`D_MEM_ADDR_WIDTH-1:0]  cpu_d_addr;
   wire [`DATA_WIDTH-1:0]        cpu_d_wdata;
   wire [`DATA_WIDTH-1:0]        cpu_d_rdata;
   wire                          cpu_d_wen;

   datapath u_cpu (
      .clk              (clk),
      .rst_n            (~reset),

      .i_mem_data_in    (i_mem_dout),
      .i_mem_addr_out   (cpu_i_addr),

      .d_mem_data_in    (cpu_d_rdata),
      .d_mem_addr_out   (cpu_d_addr),
      .d_mem_data_out   (cpu_d_wdata),
      .d_mem_wen_out    (cpu_d_wen)
   );

   assign cpu_d_rdata = d_mem_doutb;

   // =====================================================
   // Memory control logic
   // =====================================================

   always @(*) begin

      i_mem_en   = 0;
      i_mem_we   = 0;
      i_mem_addr = {`I_MEM_ADDR_WIDTH{1'b0}};
      i_mem_din  = {`INSTR_WIDTH{1'b0}};

      d_mem_ena   = 0;
      d_mem_enb   = 0;
      d_mem_wea   = 0;
      d_mem_addra = {`D_MEM_ADDR_WIDTH{1'b0}};
      d_mem_addrb = {`D_MEM_ADDR_WIDTH{1'b0}};
      d_mem_dina  = {`DATA_WIDTH{1'b0}};

      if (!cpu_enable) begin
         // =========================
         // Programming mode
         // =========================

         // Write takes priority: if write_en asserted, perform a write
         if (write_en) begin
            if (cpu_addr < 32'd512) begin
               // Program Instruction memory only
               i_mem_en   = 1;
               i_mem_addr = cpu_addr[`I_MEM_ADDR_WIDTH-1:0];
               // Zero-extend or truncate cpu_wdata into instr width if needed
               i_mem_din  = cpu_wdata[`INSTR_WIDTH-1:0];
               i_mem_we   = 1;

               // Ensure data memory ports are idle during this instruction write
               d_mem_ena  = 0;
               d_mem_enb  = 0;
               d_mem_wea  = 0;
            end
            else begin
               // Program Data memory only (address decode: addr >= 512)
               d_mem_ena   = 1;
               d_mem_addra = cpu_addr[`D_MEM_ADDR_WIDTH-1:0];
               d_mem_dina  = cpu_wdata;
               d_mem_wea   = 1;

               // Ensure instruction memory port is idle during this data write
               i_mem_en = 0;
               i_mem_we = 0;

               // For readback port B keep disabled unless a read command
               d_mem_enb = 0;
            end
         end
         else if (read_en) begin
            // Readback request: enable the correct read port (no writes)
            if (cpu_addr < 32'd512) begin
               // Read from instruction memory
               i_mem_en   = 1;
               i_mem_addr = cpu_addr[`I_MEM_ADDR_WIDTH-1:0];
               // d_mem ports idle
               d_mem_ena  = 0;
               d_mem_enb  = 0;
            end
            else begin
               // Read from data memory (port B for readback)
               d_mem_enb   = 1;
               d_mem_addrb = cpu_addr[`D_MEM_ADDR_WIDTH-1:0];
               // Keep port A idle for programming
               d_mem_ena = 0;
               d_mem_wea = 0;
               i_mem_en  = 0;
               i_mem_we  = 0;
            end
         end
         else begin
            // Neither read nor write: keep memories idle in programming mode
            i_mem_en = 0;
            d_mem_ena = 0;
            d_mem_enb = 0;
         end
      end
      else begin
         // =========================
         // CPU execution mode
         // =========================

         // Instruction fetch
         i_mem_en   = 1;
         i_mem_addr = cpu_i_addr;

         // Data memory access (Port A)
         d_mem_ena   = 1;
         d_mem_addra = cpu_d_addr;
         d_mem_dina  = cpu_d_wdata;
         d_mem_wea   = cpu_d_wen;

         // Disable readback port during CPU execution
         d_mem_enb = 0;
      end
   end

   // =====================================================
   // Readback register
   always @(posedge clk) begin
      if (reset) begin
         cpu_rdata <= 32'b0;
      end
      else begin
         if (read_en) begin
            if (cpu_addr < 32'd512) begin
               // Instruction memory width may be 32; extend/truncate to 32 bits
               cpu_rdata <= {{(32-`INSTR_WIDTH){1'b0}}, i_mem_dout};
            end
            else begin
               cpu_rdata <= d_mem_doutb;
            end
         end
      end
   end

endmodule
