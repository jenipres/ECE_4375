`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module imm_extend(
    input  wire [27:0] imm28,
    output wire [31:0] imm32
);

    // Sign-extend the 28-bit immediate to 32 bits
    assign imm32 = {{4{imm28[27]}}, imm28};

endmodule
