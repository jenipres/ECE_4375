`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module if_id_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        flush,

    input  wire [31:0] pc_in,
    input  wire [48:0] instr_in,

    output reg  [31:0] pc_out,
    output reg  [48:0] instr_out
);

    // Holds instruction and PC between fetch and decode stages
    always @(posedge clk) begin
        if (reset) begin
            pc_out    <= 32'd0;
            instr_out <= 49'd0;
        end
        else if (flush) begin
            // Clear instruction when branch or stall happens
            pc_out    <= 32'd0;
            instr_out <= 49'd0;   // insert bubble (do nothing instruction)
        end
        else if (enable) begin
            // Normal operation: pass values forward
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end

endmodule