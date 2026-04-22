`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module alu32(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_op,
    output reg  [31:0] result,
    output wire        zero
);

    // Codes for each ALU operation
    localparam ALU_ADD  = 4'd0;
    localparam ALU_SUB  = 4'd1;
    localparam ALU_AND  = 4'd2;
    localparam ALU_OR   = 4'd3;
    localparam ALU_XOR  = 4'd4;
    localparam ALU_NOT  = 4'd5;
    localparam ALU_SHL  = 4'd6;
    localparam ALU_SHR  = 4'd7;
    localparam ALU_PASS = 4'd8;

    // Perform operation based on control signal
    always @(*) begin
        case (alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_AND:  result = a & b;
            ALU_OR:   result = a | b;
            ALU_XOR:  result = a ^ b;
            ALU_NOT:  result = ~a;
            ALU_SHL:  result = a << b[4:0];
            ALU_SHR:  result = a >> b[4:0];
            ALU_PASS: result = b;
            default:  result = 32'd0;
        endcase
    end

    // Set to 1 when result is zero (used for branches)
    assign zero = (result == 32'd0);

endmodule