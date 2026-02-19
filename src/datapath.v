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
	 reg wregen_id;
	 reg wmemen_id;
	 reg mem_to_reg_id;
	 reg [1:0] cond_id;
	 reg [3:0] alu_op_id;
	 reg alu_src_id;
	 reg [`DATA_WIDTH-1:0] imm_id;
	 reg [`REG_ADDR_WIDTH-1:0] wreg1_id;
	 reg [`REG_ADDR_WIDTH-1:0] reg1_id;
	 reg [`REG_ADDR_WIDTH-1:0] reg2_id;
	 wire [`DATA_WIDTH-1:0] r1out_id;
	 wire [`DATA_WIDTH-1:0] r2out_id;

    // EX (Execute)
	 wire wregen_ex;
	 wire wmemen_ex;
	 wire mem_to_reg_ex;
	 wire [1:0] cond_ex;
	 wire [3:0] alu_op_ex;
	 wire alu_src_ex;
	 wire [`DATA_WIDTH-1:0] imm_ex;
	 wire [`REG_ADDR_WIDTH-1:0] wreg1_ex;
	 wire [`DATA_WIDTH-1:0] r1out_ex;
	 wire [`DATA_WIDTH-1:0] r2out_ex;
	 wire [`DATA_WIDTH-1:0] alu_operand_b;
	 wire [`DATA_WIDTH-1:0] alu_result_ex;

    // MEM (Memory)
	 wire wregen_mem;
	 wire wmemen_mem;
	 wire mem_to_reg_mem;
	 wire [`REG_ADDR_WIDTH-1:0] wreg1_mem;
	 wire [`DATA_WIDTH-1:0] r1out_mem;
	 wire [`DATA_WIDTH-1:0] r2out_mem;
	 wire [`DATA_WIDTH-1:0] d_mem_data_mem;
	 wire [`DATA_WIDTH-1:0] alu_result_mem;


    // WB (Write Back)
	 wire wregen_wb;
	 wire mem_to_reg_wb;
	 wire [`REG_ADDR_WIDTH-1:0] wreg1_wb;
	 wire [`DATA_WIDTH-1:0] d_mem_data_wb;
	 wire [`DATA_WIDTH-1:0] alu_result_wb;
	 wire [`DATA_WIDTH-1:0] write_data;

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
		wmemen_id = 1'b0;
		wregen_id = 1'b0;
		mem_to_reg_id = 1'b0;	 
		reg1_id = 4'b0;
		reg2_id = 4'b0;
		wreg1_id = 4'b0;
		cond_id = 2'b0;
		alu_op_id = 4'b0;
		alu_src_id = 1'b0;
		imm_id = 64'b0;

	 	case(major_op)
			2'b00:	begin	//R-type and I-type
				wregen_id = 1'b1;
				reg1_id = instr_id[28:25];
				reg2_id = instr_id[24:21];
				wreg1_id = instr_id[20:17];
				alu_op_id = instr_id[16:13];
				alu_src_id = instr_id[12];
				imm_id = {{(64-12){instr_id[11]}}, instr_id[11:0]};
			end
			2'b01: begin	//LW
				wregen_id = 1'b1;	//regWrite
				mem_to_reg_id = 1'b1;
				reg1_id = instr_id[28:25];
				wreg1_id = instr_id[24:21];
				alu_op_id = 4'b0;	// Force add
				alu_src_id = 1'b1;	// Force use offset
				imm_id = {{(64-21){instr_id[20]}}, instr_id[20:0]};
			end
			2'b10: begin	//SW
				wmemen_id = 1'b1;	//memWrite
				reg1_id = instr_id[28:25];
				reg2_id = instr_id[24:21];
				alu_op_id = 4'b0;	// Force add
				alu_src_id = 1'b1;	// Force use offset
				imm_id = {{(64-21){instr_id[20]}}, instr_id[20:0]};
			end
			2'b11: begin	//Branch
				cond_id = instr_id[29:28];
				imm_id = {{(64-28){instr_id[27]}}, instr_id[27:0]};
			end
		endcase
	 end
	
	 regfile u_regfile (
		.clk(clk),
		.wena(wregen_wb),
      .waddr(wreg1_wb),
      .wdata(write_data),
      .r0addr(reg1_id),
      .r1addr(reg2_id),
      .r0data(r1out_id),
      .r1data(r2out_id)
    );
	 
	 pipeline_reg #(.REGS(1+1+1+`DATA_WIDTH+`DATA_WIDTH+`REG_ADDR_WIDTH+2+4+1+`DATA_WIDTH)) id_ex_stage(
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D({wregen_id, wmemen_id, mem_to_reg_id, r1out_id, r2out_id, wreg1_id, cond_id, alu_op_id, alu_src_id, imm_id}),
		.Q({wregen_ex, wmemen_ex, mem_to_reg_ex, r1out_ex, r2out_ex, wreg1_ex, cond_ex, alu_op_ex, alu_src_ex, imm_ex})
	 );

    // EX (Execute)
	assign alu_operand_b = (!alu_src_ex) ? r2out_ex : imm_ex;

	alu u_alu (
		.clk(clk),
		.reset(~rst_n),
		.A(r1out_ex),
		.B(alu_operand_b), 
		.op(alu_op_ex),
		.ALU_out(alu_result_ex)
	);

	 pipeline_reg #(.REGS(1+1+1+`DATA_WIDTH+`DATA_WIDTH+`REG_ADDR_WIDTH+`DATA_WIDTH)) ex_mem_stage(
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D({wregen_ex, wmemen_ex, mem_to_reg_ex, r1out_ex, r2out_ex, wreg1_ex, alu_result_ex}),
		.Q({wregen_mem, wmemen_mem, mem_to_reg_mem, r1out_mem, r2out_mem, wreg1_mem, alu_result_mem})
	 );

    // MEM (Memory)
	 assign d_mem_addr_out = alu_result_mem;
	 assign d_mem_data_out = r2out_mem;
	 assign d_mem_wen_out = wmemen_mem;
	 assign d_mem_data_mem = d_mem_data_in;
	 
	 pipeline_reg #(.REGS(1+1+`DATA_WIDTH+`REG_ADDR_WIDTH+`DATA_WIDTH)) mem_wb_stage(
		.clk(clk),
		.rst_n(rst_n),
		.en(1'b1),
		.D({wregen_mem, mem_to_reg_mem, d_mem_data_mem, wreg1_mem, alu_result_mem}),
		.Q({wregen_wb, mem_to_reg_wb, d_mem_data_wb, wreg1_wb, alu_result_wb})
	 );

    // WB (Write Back)
	 assign write_data = (mem_to_reg_wb) ? d_mem_data_wb : alu_result_wb;

endmodule

