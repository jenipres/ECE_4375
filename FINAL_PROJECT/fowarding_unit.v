`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module handles simple data forwarding for the execute stage. Forwarding
is used when an instruction needs a register value that was just produced by
a previous instruction but has not fully written back to the register file yet.

The forwarding unit compares the source registers in the ID/EX stage with the
destination register in the EX/MEM/WB stage.

Outputs:
forward_a - selects forwarded data for ALU operand A / rs1
forward_b - selects forwarded data for ALU operand B / rs2 or store data
*/

module forwarding_unit(
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,

    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,

    output wire       forward_a,
    output wire       forward_b
);

    // ============================================================
    // Forwarding Decision for Operand A
    // ============================================================
    // Forward to operand A when:
    // 1. The later pipeline stage will write to a register.
    // 2. The destination register is not R0.
    // 3. The destination register matches the current rs1.
    assign forward_a = ex_mem_reg_write &&
                       (ex_mem_rd != 5'd0) &&
                       (id_ex_rs1 == ex_mem_rd);

    // ============================================================
    // Forwarding Decision for Operand B
    // ============================================================
    // Forward to operand B when:
    // 1. The later pipeline stage will write to a register.
    // 2. The destination register is not R0.
    // 3. The destination register matches the current rs2.
    assign forward_b = ex_mem_reg_write &&
                       (ex_mem_rd != 5'd0) &&
                       (id_ex_rs2 == ex_mem_rd);

endmodule
