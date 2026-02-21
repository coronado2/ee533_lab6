`timescale 1ns / 1ps
// CPU_test module
// Combines CPU with Memory Blocks

`include "defines.v"

module top(
	 input wire clk,
	 input wire rst_n
    );
	 
	 wire [`PC_WIDTH-1:0] i_mem_addr_out;
	 wire [`INSTR_WIDTH-1:0] i_mem_data_in;
	 wire d_mem_wren;
	 wire [`D_MEM_ADDR_WIDTH-1:0] d_mem_addr_out;
	 wire [`DATA_WIDTH-1:0] d_mem_data_in;
	 wire [`DATA_WIDTH-1:0] d_mem_data_out;
	 wire cpu_done;
	 
	 i_mem u_i_mem(
		.addr(i_mem_addr_out[8:0]),
		.clk(clk),
		.dout(i_mem_data_in)
	 );
	 
	 datapath u_datapath(
		.clk(clk),
		.rst_n(rst_n),
		.i_mem_data_in(i_mem_data_in),
		.i_mem_addr_out(i_mem_addr_out),
		.d_mem_addr_out(d_mem_addr_out),
		.d_mem_data_in(d_mem_data_in),
		.d_mem_data_out(d_mem_data_out),
		.d_mem_wen_out(d_mem_wren),
		.cpu_done(cpu_done)
	 );
	 
	 d_mem u_d_mem(
		.addr(d_mem_addr_out[7:0]),
		.clk(clk),
		.din(d_mem_data_out),
		.dout(d_mem_data_in),
		.we(d_mem_wren)
	 );
	 
endmodule
