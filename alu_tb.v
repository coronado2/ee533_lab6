`timescale 1ns / 1ps

module alu_tb;
    reg clk;
    reg reset;
    reg [63:0] A;
    reg [63:0] B;
    reg [3:0] op;
    
    wire [63:0] ALU_out;

    alu uut(
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .op(op),
        .ALU_out(ALU_out)
    );

    // clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulus
    initial begin
        reset = 1'b1;
        A = 0; B = 0; op = 0;
        #10;
        reset = 1'b0;
        #10;

        // ADD TESTS
        A = 64'd10; B = 64'd5; op = 4'b0000; #10;
        A = 64'hFFFFFFFFFFFFFFFF; B = 64'd1; op = 4'b0000; #10;
        A = 64'h7FFFFFFFFFFFFFFF; B = 64'd1; op = 4'b0000; #10;

        // SUB TESTS
        A = 64'd10; B = 64'd3; op = 4'b0001; #10;
        A = 64'd3; B = 64'd10; op = 4'b0001; #10;
        A = 64'h8000000000000000; B = 64'd1; op = 4'b0001; #10;

        // SLT
        A = -5;  B = 2;  op = 4'b0010; #10;
        A = 5;   B = -2; op = 4'b0010; #10;
        A = -10; B = -3; op = 4'b0010; #10;

        // SLTU
        A = 5; B = 10; op = 4'b0011; #10;
        A = 64'hFFFFFFFFFFFFFFFF; B = 1; op = 4'b0011; #10;
        A = -1; B = 5; op = 4'b0011; #10;

        // AND, OR, XNOR
        A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; op = 4'b0100; #10;
        A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; op = 4'b0101; #10;
        A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555; op = 4'b0110; #10;

        // SHIFT
        A = 64'd1; B = 4; op = 4'b0111; #10;
        A = 64'h8000000000000000; B = 1; op = 4'b0111; #10;
        A = 64'h123456789ABCDEF0; B = 63; op = 4'b1000; #10;

        // EQUAL
        A = 64'd10; B = 64'd10; op = 4'b1001; #10;
        A = 64'd10; B = 64'd11; op = 4'b1001; #10;
        A = 64'hDEADBEEFCAFEBABE; B = 64'hDEADBEEFCAFEBABE; op = 4'b1001; #10;
    end
endmodule
