`timescale 1ns / 1ps
// Simple 2-read, 1-write register file with reset

`include "defines.v"

module regfile (
    input  wire                       clk,
    input  wire                       rst_n,

    // Write port
    input  wire                       wena,
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

    integer i;

    // Read logic (combinational)
    assign r0data = regs[r0addr];
    assign r1data = regs[r1addr];

    // Write + reset logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < (1<<`REG_ADDR_WIDTH); i = i + 1)
                regs[i] <= {`DATA_WIDTH{1'b0}};
        end
        else if (wena) begin
            regs[waddr] <= wdata;
        end
    end

endmodule