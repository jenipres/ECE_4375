`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module handles branch decisions for the CPU execute stage. It calculates
the branch target address and determines whether the program counter should
jump based on the branch control signal and branch type.

Supported branch types:
BZ   - branch if rs1_value is zero
BNZ  - branch if rs1_value is not zero
BRA  - unconditional branch

Branch target:
branch_target = pc_current + imm32
*/

module branch_unit(
    input  wire [31:0] pc_current,
    input  wire [31:0] rs1_value,
    input  wire [31:0] imm32,
    input  wire        branch,
    input  wire [1:0]  branch_type,
    output reg         branch_taken,
    output wire [31:0] branch_target
);

    // ============================================================
    // Branch Target Calculation
    // ============================================================
    // The immediate value is used as a relative offset from the
    // current PC. This supports forward and backward branches.
    assign branch_target = pc_current + imm32;

    // ============================================================
    // Branch Decision Logic
    // ============================================================
    // branch_taken is only asserted when the instruction is a branch
    // and its condition is true.
    always @(*) begin
        // Default: do not branch
        branch_taken = 1'b0;

        if (branch) begin
            case (branch_type)
                2'b01: branch_taken = (rs1_value == 32'd0); // BZ: branch if zero
                2'b10: branch_taken = (rs1_value != 32'd0); // BNZ: branch if not zero
                2'b11: branch_taken = 1'b1;                 // BRA: always branch
                default: branch_taken = 1'b0;               // Safe default
            endcase
        end
    end

endmodule
