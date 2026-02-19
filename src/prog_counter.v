`timescale 1ns / 1ps
// Program counter module
module prog_counter #(
    parameter PC_WIDTH = `PC_WIDTH
)(
    input  wire                 clk,
    input  wire                 rst_n,   // active-low reset
    input  wire                 en,      // enable
    input  wire                 br,
    input  wire [PC_WIDTH-1:0]  br_target,
    output reg  [PC_WIDTH-1:0]  pc_out
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc_out <= {PC_WIDTH{1'b0}};
    end
    else if (en) begin
        if (!br)
            pc_out <= br_target;
        else
            pc_out <= pc_out + 1;
    end
end

endmodule

