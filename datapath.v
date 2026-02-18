`timescale 1ns / 1ps
// CPU module

`include "defines.v"

module datapath (
    input  wire                     clk,
    input  wire                     rst_n,

    // Instruction memory interface
    input  wire [`INSTR_WIDTH-1:0] i_mem_data_in,
    output wire [`PC_WIDTH-1:0]          i_mem_addr_out,

    // Data memory interface
    input  wire [`DATA_WIDTH-1:0]        d_mem_data_in,
    output wire [`D_MEM_ADDR_WIDTH-1:0]  d_mem_addr_out,
    output wire [`DATA_WIDTH-1:0]        d_mem_data_out,
    output wire                          d_mem_wen_out
);

    // ============================================================
    // 5-Stage Pipeline Signals
    // ============================================================

    // IF (Instruction Fetch)
	 wire [`PC_WIDTH-1:0] pc_if;
	 wire [`INSTR_WIDTH-1:0] instr_if;
	 wire pc_en;
	 assign pc_en = 1'b1; // update pc every clock

    // ID (Decode)
	 wire [`INSTR_WIDTH-1:0] instr_id;
	 wire wregen_id;
	 wire wmemen_id;
	 wire [`REG_ADDR_WIDTH-1:0] wreg1_id;
	 wire [`REG_ADDR_WIDTH-1:0] reg1_id;
	 wire [`REG_ADDR_WIDTH-1:0] reg2_id;
	 wire [`DATA_WIDTH-1:0] r1out_id;
	 wire [`DATA_WIDTH-1:0] r2out_id;

    // EX (Execute)
	 wire wregen_ex;
	 wire wmemen_ex;
	 wire [`REG_ADDR_WIDTH-1:0] wreg1_ex;
	 wire [`DATA_WIDTH-1:0] r1out_ex;
	 wire [`DATA_WIDTH-1:0] r2out_ex;

    // MEM (Memory)
	 wire wregen_mem;
	 wire wmemen_mem;
	 wire [`REG_ADDR_WIDTH-1:0] wreg1_mem;
	 wire [`DATA_WIDTH-1:0] r1out_mem;
	 wire [`DATA_WIDTH-1:0] r2out_mem;
	 wire [`DATA_WIDTH-1:0] d_mem_data_mem;

    // WB (Write Back)
	 wire wregen_wb;
	 wire [`REG_ADDR_WIDTH-1:0] wreg1_wb;
	 wire [`DATA_WIDTH-1:0] d_mem_data_wb;

	 // ============================================================
    // 5-Stage Pipeline Logic
    // ============================================================

    // IF (Instruction Fetch)
	 prog_counter u_prog_counter(
		.clk(clk),
		.rst_n(rst_n),
		.en(pc_en),
		.pc_out(pc_if)
	 );
	 
	 assign i_mem_addr_out = pc_if;
	 assign instr_if = i_mem_data_in;
	 
	 pipeline_reg #(.REGS(`INSTR_WIDTH)) if_id_stage (
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D(instr_if),
		.Q(instr_id)
	 );

    // ID (Decode)
	 assign wmemen_id = instr_id[31];
	 assign wregen_id = instr_id[30];
	 assign reg1_id = instr_id[28:27];
	 assign reg2_id = instr_id[25:24];
	 assign wreg1_id = instr_id[22:21];
	 
	 regfile u_regfile (
		.clk(clk),
		.wena(wregen_wb),
      .waddr(wreg1_wb),
      .wdata(d_mem_data_wb),
      .r0addr(reg1_id),
      .r1addr(reg2_id),
      .r0data(r1out_id),
      .r1data(r2out_id)
    );
	 
	 pipeline_reg #(.REGS(1+1+`DATA_WIDTH+`DATA_WIDTH+`REG_ADDR_WIDTH)) id_ex_stage(
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D({wregen_id, wmemen_id, r1out_id, r2out_id, wreg1_id}),
		.Q({wregen_ex, wmemen_ex, r1out_ex, r2out_ex, wreg1_ex})
	 );

    // EX (Execute)
	 pipeline_reg #(.REGS(1+1+`DATA_WIDTH+`DATA_WIDTH+`REG_ADDR_WIDTH)) ex_mem_stage(
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D({wregen_ex, wmemen_ex, r1out_ex, r2out_ex, wreg1_ex}),
		.Q({wregen_mem, wmemen_mem, r1out_mem, r2out_mem, wreg1_mem})
	 );

    // MEM (Memory)
	 assign d_mem_addr_out = r1out_mem;
	 assign d_mem_data_out = r2out_mem;
	 assign d_mem_wen_out = wmemen_mem;
	 assign d_mem_data_mem = d_mem_data_in;
	 
	 pipeline_reg #(.REGS(1+`DATA_WIDTH+`REG_ADDR_WIDTH)) mem_wb_stage(
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D({wregen_mem, d_mem_data_mem, wreg1_mem}),
		.Q({wregen_wb, d_mem_data_wb, wreg1_wb})
	 );

    // WB (Write Back)
	 // Nothing to assign in WB

endmodule

