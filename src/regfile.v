`timescale 1ns / 1ps
// Simple 2-read, 1-write register file

`include "defines.v"

module regfile (
    input  wire                     clk,

    // Write port
    input  wire                     wena,
    input  wire [`REG_ADDR_WIDTH-1:0] waddr,
    input  wire [`DATA_WIDTH-1:0]     wdata,

    // Read ports
    input  wire [`REG_ADDR_WIDTH-1:0] r0addr,
    input  wire [`REG_ADDR_WIDTH-1:0] r1addr,
    output wire [`DATA_WIDTH-1:0]     r0data,
    output wire [`DATA_WIDTH-1:0]     r1data
);

    // 2^REG_ADDR_WIDTH registers
    reg [`DATA_WIDTH-1:0] regs [0:(1<<`REG_ADDR_WIDTH)-1];

    // Read logic
    assign r0data = regs[r0addr];
    assign r1data = regs[r1addr];

    // Write logic
    always @(posedge clk) begin
        if (wena) begin
            regs[waddr] <= wdata;
        end
    end

endmodule
