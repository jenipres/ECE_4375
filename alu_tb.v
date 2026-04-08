`timescale 1ns / 1ps

module alu_tb;

    reg  [31:0] busA;
    reg  [31:0] busB;
    reg  [4:0]  ALUOp;

    wire [31:0] result;
    wire z, n, c, v;

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
    // Operation encoding (control unit will drive ALUOp)
    localparam ADD = 5'b00000;
    localparam SUB = 5'b00001;
    localparam NOT = 5'b00010;
    localparam AND = 5'b00011;
    localparam OR  = 5'b00100;
    localparam XOR = 5'b00101;
    localparam SHR = 5'b00110;
    localparam SHL = 5'b00111;
    localparam LD  = 5'b01000;

    initial begin
        $display("Starting ALU testbench...");
        $monitor("T=%0t ALUOp=%b busA=%h busB=%h result=%h Z=%b N=%b C=%b V=%b",
                  $time, ALUOp, busA, busB, result, z, n, c, v);

        // ADD
        busA = 32'd15; busB = 32'd10; ALUOp = ADD; #10;

        // SUB
        busA = 32'd20; busB = 32'd5;  ALUOp = SUB; #10;

        // NOT
        busA = 32'h0000FFFF; busB = 32'd0; ALUOp = NOT; #10;

        // AND
        busA = 32'hF0F0F0F0; busB = 32'h0FF00FF0; ALUOp = AND; #10;

        // OR
        busA = 32'hF0F0F0F0; busB = 32'h0FF00FF0; ALUOp = OR; #10;

        // XOR
        busA = 32'hAAAA5555; busB = 32'hFFFF0000; ALUOp = XOR; #10;

        // SHR
        busA = 32'h000000F0; busB = 32'd4; ALUOp = SHR; #10;

        // SHL
        busA = 32'h0000000F; busB = 32'd4; ALUOp = SHL; #10;

        // LD
        busA = 32'h12345678; busB = 32'hFFFFFFFF; ALUOp = LD; #10;

        // Zero flag test
        busA = 32'd5; busB = 32'd5; ALUOp = SUB; #10;

        // Negative flag test
        busA = 32'd5; busB = 32'd10; ALUOp = SUB; #10;

        // Overflow test for ADD
        busA = 32'h7FFFFFFF; busB = 32'd1; ALUOp = ADD; #10;

        // Overflow test for SUB
        busA = 32'h80000000; busB = 32'd1; ALUOp = SUB; #10;

        $display("ALU testbench complete.");
        $finish;
    end

endmodule
