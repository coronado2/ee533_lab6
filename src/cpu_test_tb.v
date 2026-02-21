`timescale 1ns/1ps

module cpu_test_tb;

  reg clk;
  reg rst_n;

  cpu_test dut (
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
  end

// Cycle coutner
integer cycle;
initial cycle = 0;
always @(posedge clk) begin
  if(!rst_n) cycle <=0;
  else 
    cycle <= cycle + 1;
end

  // Header
  initial begin
    $display(" Cycle | PC_if   instr_if  | PC_id  instr_id  br_en_id  cond_id  alu_op_id | PC_ex  pc_mux_ex  cond_ex  alu_op_ex | PC_mem  pc_mux_mem  alu_result_mem | PC_wb  pc_mux_wb  wdata ");
  end

  // Print on falling edge up to 130ns
  always @(negedge clk) begin
    if (rst_n) begin
      $display("%3d  | 0x%08h  0x%08h | 0x%08h  0x%08h    %0b      %0b     0x%0h   | 0x%08h    %0b       %0b     0x%0h   | 0x%08h    %0b      0x%016h | 0x%08h    %0b     0x%016h",
        cycle,
        //IF
        dut.u_datapath.pc_if,
        dut.i_mem_data_in,

        //ID
        dut.u_datapath.pc_id,
        dut.u_datapath.instr_id,
        dut.u_datapath.br_en_id,
        dut.u_datapath.cond_id,
        dut.u_datapath.alu_op_id,

        //EX
        dut.u_datapath.pc_ex,
        dut.u_datapath.pc_mux_sel_ex,
        dut.u_datapath.cond_ex,
        dut.u_datapath.alu_op_ex,

        //MEM
        dut.u_datapath.pc_mem,
        dut.u_datapath.pc_mux_sel_mem,
        dut.u_datapath.alu_result_mem,

        //WB
        dut.u_datapath.pc_wb,
        dut.u_datapath.pc_mux_sel_wb,
        dut.u_datapath.write_data
      );
    end
  end

  // Waves
  initial begin
    $dumpfile("cpu_test_tb.vcd");
    $dumpvars(0, cpu_test_tb);             // everything inside cpu
	 $dumpvars(0, dut.u_datapath);
  end

initial begin
  repeat (200) @(posedge clk);
  $finish;
end

endmodule
