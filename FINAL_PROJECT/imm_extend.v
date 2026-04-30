`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module sign-extends the 28-bit immediate field from the 49-bit
instruction format into a 32-bit value used by the CPU datapath.

The extended immediate is used for:
- Immediate ALU operations
- Load/store address offsets
- Branch offsets
- LD immediate writeback

Sign extension keeps negative branch offsets and negative immediates working
correctly by copying imm28[27] into the upper 4 bits of imm32.
*/

module imm_extend(
    input  wire [27:0] imm28,
    output wire [31:0] imm32
);

    // ============================================================
    // Sign Extension
    // ============================================================
    // imm28[27] is the sign bit of the 28-bit immediate.
    // If imm28[27] = 1, the upper 4 bits become 1111.
    // If imm28[27] = 0, the upper 4 bits become 0000.
    assign imm32 = {{4{imm28[27]}}, imm28};

endmodule
