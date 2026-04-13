`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 3
*/
module alu_tb;

    reg  [31:0] busA;
    reg  [31:0] busB;
    reg  [4:0]  ALUOp;

    wire [31:0] result;
    wire z, n, c, v;

    // Required opcode values from project sheet
    localparam LD  = 5'h01;
    localparam ADD = 5'h03;
    localparam SUB = 5'h04;
    localparam AND = 5'h05;
    localparam OR  = 5'h06;
    localparam XOR = 5'h07;
    localparam NOT = 5'h08;
    localparam SHL = 5'h09;
    localparam SHR = 5'h0A;

    alu dut (
        .busA(busA),
        .busB(busB),
        .ALUOp(ALUOp),
        .result(result),
        .z(z),
        .n(n),
        .c(c),
        .v(v)
    );

    initial begin
        $display("Starting ALU testbench...");
        $monitor("T=%0t ALUOp=%h busA=%h busB=%h result=%h Z=%b N=%b C=%b V=%b",
                 $time, ALUOp, busA, busB, result, z, n, c, v);

        // LD
        busA = 32'h12345678; busB = 32'hFFFFFFFF; ALUOp = LD;  #10;

        // ADD
        busA = 32'd15;       busB = 32'd10;       ALUOp = ADD; #10;

        // SUB
        busA = 32'd20;       busB = 32'd5;        ALUOp = SUB; #10;

        // NOT
        busA = 32'h0000FFFF; busB = 32'd0;        ALUOp = NOT; #10;

        // AND
        busA = 32'hF0F0F0F0; busB = 32'h0FF00FF0; ALUOp = AND; #10;

        // OR
        busA = 32'hF0F0F0F0; busB = 32'h0FF00FF0; ALUOp = OR;  #10;

        // XOR
        busA = 32'hAAAA5555; busB = 32'hFFFF0000; ALUOp = XOR; #10;

        // SHR
        busA = 32'h000000F0; busB = 32'd4;        ALUOp = SHR; #10;

        // SHL
        busA = 32'h0000000F; busB = 32'd4;        ALUOp = SHL; #10;

        // Zero flag test
        busA = 32'd5;        busB = 32'd5;        ALUOp = SUB; #10;

        // Negative flag test
        busA = 32'd5;        busB = 32'd10;       ALUOp = SUB; #10;

        // Overflow test for ADD
        busA = 32'h7FFFFFFF; busB = 32'd1;        ALUOp = ADD; #10;

        // Overflow test for SUB
        busA = 32'h80000000; busB = 32'd1;        ALUOp = SUB; #10;

        $display("ALU testbench complete.");
        $finish;
    end

endmodule
