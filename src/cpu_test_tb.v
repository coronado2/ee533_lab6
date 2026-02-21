`timescale 1ns/1ps

module cpu_test_tb;

  reg clk;
  reg rst_n;

  // DUT
  cpu_test dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // clock: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // reset
  initial begin
    rst_n = 0;
    repeat(5) @(posedge clk);
    rst_n = 1;
  end

  integer cyc;
  initial cyc = 0;
  always @(posedge clk) begin
    if (!rst_n) cyc <= 0;
    else        cyc <= cyc + 1;
  end

  // Pretty header
  initial begin
    $display("cyc | pc_if      imem_addr  imem_dout  | instr_id   major | WB: wena waddr wdata");
    $display("----+----------------------------------+--------------------+------------------------");
  end

  always @(negedge clk) begin
    if (rst_n) begin
      $display("%3d | %08h  %08h  %08h | %08h    %02b   |     %0d   %02h  %016h",
        cyc,

        // PC in IF 
        dut.u_datapath.pc_if,

        dut.i_mem_addr_out,
        dut.i_mem_data_in,

        dut.u_datapath.instr_id,
        dut.u_datapath.major_op,

        dut.u_datapath.wregen_wb,
        dut.u_datapath.wreg1_wb,
        dut.u_datapath.write_data
      );
    end
  end

  initial begin
    repeat(40) @(posedge clk);
    $finish;
  end

endmodule