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
	 wire [1:0] major_op;
	 reg [3:0] alu_op;
	 reg [1:0] cond;
	 reg [12:0] imm13;
	 reg [20:0] offset;
	 reg [27:0] pc_offset;
	 reg wregen_id;
	 reg wmemen_id;
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
	 assign major_op = instr_id[31:30];	// ALU: 00, LW: 01, SW: 10, 11 Branch
	 always @(*) begin
		reg1_id = 4'b0;
		reg2_id = 4'b0;
		cond = 2'b0;
		wreg1_id = 4'b0;
		alu_op = 4'b0;
		imm13 = 13'b0;
		offset = 21'b0;
		pc_offset = 28'b0;
		wmemen_id = 1'b0;
		wreg1_id = 1'b0;

	 	case(major_op)
			2'b00:	begin	//R-type and I-type
				reg1_id = instr_id[28:25];
				reg2_id = instr_id[24:21];
				wreg1_id = instr_id[20:17];
				alu_op = instr_id[16:13];
				imm13 = instr_id[12:0];
			end
			2'b01: begin	//LW
				reg1_id = instr_id[28:25];
				wreg1_id = instr_id[24:21];
				offset = instr_id[20:0];
				wreg1_id = 1'b1;	//regWrite
			end
			2'b10: begin	//SW
				reg1_id = instr_id[28:25];
				reg2_id = instr_id[24:21];
				offset = instr_id[20:0];
				wmemen_id = 1'b1;	//memWrite
			end
			2'b11: begin	//Branch
				cond = instr_id[29:28];
				pc_offset = instr_id[27:0];
			end
		endcase
	 end
	
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
	 
	 pipeline_reg #(.REGS(2+4+13+21+28+`DATA_WIDTH+`DATA_WIDTH+`REG_ADDR_WIDTH)) id_ex_stage(
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D({wregen_id, wmemen_id, r1out_id, r2out_id, wreg1_id}),
		.Q({wregen_ex, wmemen_ex, r1out_ex, r2out_ex, wreg1_ex})
	 );

    // EX (Execute)
	alu u_alu (
		.clk(clk),
		.reset(rst_n),
		.A(r1out_id),
		.B(r2out_id), //temp need to mux with imm13 and offsets
		.op(),	//alu op
		.ALU_out()
	)

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

