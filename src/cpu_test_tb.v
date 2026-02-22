`timescale 1ns/1ps

module cpu_test_tb;

  reg clk;
  reg rst_n;

  cpu_test dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // clock
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

  // header
  initial begin
    $display("");
    $display("cyc | IF:pc       IM:addr    IM:dout    || ID:pc       ID:instr   op || EX:alu_res  pc_sel || MEM:we addr  wdata               rdata               || WB:we rd wdata");
    $display("----+----------------------------------++--------------------------------+---------------------+-----------------------------------------------+---------------------------");
  end

  // cycle trace
  always @(negedge clk) begin
    if (rst_n) begin
      $display(
        "%3d | %08h  %08h  %08h || %08h  %08h  %02b || %08h     %1d    ||   %1d  %04h  %016h  %016h ||   %1d  %02h  %016h",
        cyc,
        dut.u_datapath.pc_if,
        dut.i_mem_addr_out,
        dut.i_mem_data_in,
        dut.u_datapath.pc_id,
        dut.u_datapath.instr_id,
        dut.u_datapath.major_op,
        dut.u_datapath.alu_result_ex,
        dut.u_datapath.pc_mux_sel_ex,
        dut.u_datapath.wmemen_mem,
        dut.d_mem_addr_out,
        dut.d_mem_data_out,
        dut.d_mem_data_in,
        dut.u_datapath.wregen_wb,
        dut.u_datapath.wreg1_wb,
        dut.u_datapath.write_data
      );

      if (dut.u_datapath.wmemen_mem)
        $display("      STORE  MEM[%0d] <= %016h", dut.d_mem_addr_out, dut.d_mem_data_out);

      if (dut.u_datapath.wregen_wb)
        $display("      WB     R[%0d] <= %016h", dut.u_datapath.wreg1_wb, dut.u_datapath.write_data);

      if (dut.u_datapath.pc_mux_sel_ex)
        $display("      BRANCH pc mux select asserted");
    end
  end

  initial begin
    repeat(400) @(posedge clk);
    $finish;
  end

endmodule