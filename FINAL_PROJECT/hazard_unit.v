`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
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

    // Check if current instruction needs a value
    // that is still being computed in the pipeline
    wire hazard_idex_rs1;
    wire hazard_idex_rs2;
    wire hazard_exmem_rs1;
    wire hazard_exmem_rs2;

    // Hazard with instruction in EX stage
    assign hazard_idex_rs1 = dec_use_rs1 &&
                             id_ex_reg_write &&
                             (id_ex_rd != 5'd0) &&
                             (dec_rs1 == id_ex_rd);

    assign hazard_idex_rs2 = dec_use_rs2 &&
                             id_ex_reg_write &&
                             (id_ex_rd != 5'd0) &&
                             (dec_rs2 == id_ex_rd);

    // Hazard with instruction in MEM stage
    assign hazard_exmem_rs1 = dec_use_rs1 &&
                              ex_mem_reg_write &&
                              (ex_mem_rd != 5'd0) &&
                              (dec_rs1 == ex_mem_rd);

    assign hazard_exmem_rs2 = dec_use_rs2 &&
                              ex_mem_reg_write &&
                              (ex_mem_rd != 5'd0) &&
                              (dec_rs2 == ex_mem_rd);

    // Stall if any hazard is found
    assign stall = hazard_idex_rs1 || hazard_idex_rs2 ||
                   hazard_exmem_rs1 || hazard_exmem_rs2;

endmodule