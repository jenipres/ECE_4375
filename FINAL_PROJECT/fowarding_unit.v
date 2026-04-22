`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module forwarding_unit(
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,

    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,

    output wire       forward_a,
    output wire       forward_b
);

    // Forward data from a later stage if the needed value
    // has already been computed but not written back yet

    assign forward_a = ex_mem_reg_write &&
                       (ex_mem_rd != 5'd0) &&
                       (id_ex_rs1 == ex_mem_rd);

    assign forward_b = ex_mem_reg_write &&
                       (ex_mem_rd != 5'd0) &&
                       (id_ex_rs2 == ex_mem_rd);

endmodule