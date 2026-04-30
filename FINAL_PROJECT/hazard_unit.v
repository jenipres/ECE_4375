`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module detects data hazards between the instruction currently in the
decode stage and instructions already moving through the pipeline.

If the decode-stage instruction needs a source register that is still waiting
to be written by an instruction in ID/EX or EX/MEM/WB, the hazard unit asserts
stall. The top-level CPU uses stall to pause the PC and pipeline registers and
insert a bubble.

Inputs:
dec_rs1/dec_rs2       - source registers used by the instruction in decode
dec_use_rs1/rs2       - tells whether rs1 or rs2 is actually needed
id_ex_rd              - destination register of instruction in execute stage
ex_mem_rd             - destination register of instruction in later stage
id_ex_reg_write       - execute-stage instruction will write a register
ex_mem_reg_write      - later-stage instruction will write a register

Output:
stall                 - high when the pipeline should pause
*/

module hazard_unit(
    input  wire [4:0] dec_rs1,
    input  wire [4:0] dec_rs2,
    input  wire       dec_use_rs1,
    input  wire       dec_use_rs2,

    input  wire [4:0] id_ex_rd,
    input  wire       id_ex_reg_write,

    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,

    output wire       stall
);

    // ============================================================
    // Individual Hazard Signals
    // ============================================================
    // These signals check both source registers against destination
    // registers in later pipeline stages.
    wire hazard_idex_rs1;
    wire hazard_idex_rs2;
    wire hazard_exmem_rs1;
    wire hazard_exmem_rs2;

    // ============================================================
    // Hazard With Instruction in ID/EX
    // ============================================================
    // A hazard occurs if the decode-stage instruction uses rs1 or rs2
    // and the instruction in ID/EX is going to write that same register.
    assign hazard_idex_rs1 = dec_use_rs1 &&
                             id_ex_reg_write &&
                             (id_ex_rd != 5'd0) &&
                             (dec_rs1 == id_ex_rd);

    assign hazard_idex_rs2 = dec_use_rs2 &&
                             id_ex_reg_write &&
                             (id_ex_rd != 5'd0) &&
                             (dec_rs2 == id_ex_rd);

    // ============================================================
    // Hazard With Instruction in EX/MEM/WB
    // ============================================================
    // This checks for a value that is farther down the pipeline but
    // still may not be available to the decode-stage instruction yet.
    assign hazard_exmem_rs1 = dec_use_rs1 &&
                              ex_mem_reg_write &&
                              (ex_mem_rd != 5'd0) &&
                              (dec_rs1 == ex_mem_rd);

    assign hazard_exmem_rs2 = dec_use_rs2 &&
                              ex_mem_reg_write &&
                              (ex_mem_rd != 5'd0) &&
                              (dec_rs2 == ex_mem_rd);

    // ============================================================
    // Final Stall Decision
    // ============================================================
    // If any hazard is found, stall the pipeline.
    assign stall = hazard_idex_rs1 || hazard_idex_rs2 ||
                   hazard_exmem_rs1 || hazard_exmem_rs2;

endmodule
