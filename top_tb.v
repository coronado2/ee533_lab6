`timescale 1ns/1ps

module top_tb;

  reg clk;
  reg rst_n;

  top dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // Clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Reset + run
  initial begin
    rst_n = 1'b0;
    #20;
    rst_n = 1'b1;

    #500;
    $finish;
  end

  // Header
  initial begin
    $display(" time | rst | PC        | instr      | we | D_MEM addr | D_MEM Data IN            | D_MEM Data OUT");
  end

  // Print on falling edge up to 130ns
  always @(negedge clk) begin
    if ($time <= 130) begin
      $display("%4t |  %0d  | 0x%08h | 0x%08h |  %0d | 0x%02h  | 0x%016h | 0x%016h",
        $time, rst_n,
        dut.i_mem_addr_out,
        dut.i_mem_data_in,
        dut.d_mem_wren,
        dut.d_mem_addr_out,
        dut.d_mem_data_out,
        dut.d_mem_data_in
      );
    end
  end

  // Waves
  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);             // everything inside top
	 $dumpvars(0, dut.u_datapath);
  end

endmodule
