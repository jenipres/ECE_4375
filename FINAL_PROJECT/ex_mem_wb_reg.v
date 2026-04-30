`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module is the final pipeline register for the Project 5 CPU. It stores
the results from the execute stage and passes them into the memory/writeback
stage on the next clock edge.

This register carries:
- ALU result for arithmetic/logic instructions and memory addresses
- rs2 data for store instructions
- immediate value for LD immediate writeback
- destination register number
- memory and writeback control signals

Pipeline role:
EX stage  ->  EX/MEM/WB register  ->  MEM/WB stage
*/

module ex_mem_wb_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        flush,

    // Datapath inputs from the execute stage
    input  wire [31:0] alu_result_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] imm32_in,
    input  wire [4:0]  rd_in,

    // Control inputs from the execute stage
    input  wire        reg_write_in,
    input  wire        mem_write_in,
    input  wire        mem_read_in,
    input  wire [1:0]  wb_sel_in,

    // Registered datapath outputs to the memory/writeback stage
    output reg  [31:0] alu_result_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] imm32_out,
    output reg  [4:0]  rd_out,

    // Registered control outputs to the memory/writeback stage
    output reg         reg_write_out,
    output reg         mem_write_out,
    output reg         mem_read_out,
    output reg  [1:0]  wb_sel_out
);

    // ============================================================
    // Pipeline Register Update
    // ============================================================
    // reset:
    //   Clears all data/control values.
    //
    // flush:
    //   Inserts a bubble by clearing all data/control values. This prevents
    //   an unwanted instruction from writing registers or memory.
    //
    // enable:
    //   Allows the execute-stage results to move forward into MEM/WB.
    always @(posedge clk) begin
        if (reset) begin
            // Clear datapath values
            alu_result_out <= 32'd0;
            rs2_data_out   <= 32'd0;
            imm32_out      <= 32'd0;
            rd_out         <= 5'd0;

            // Clear control signals so no write or memory operation happens
            reg_write_out  <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            wb_sel_out     <= 2'b00;
        end
        else if (flush) begin
            // Flush acts like a bubble/NOP in the pipeline
            alu_result_out <= 32'd0;
            rs2_data_out   <= 32'd0;
            imm32_out      <= 32'd0;
            rd_out         <= 5'd0;

            reg_write_out  <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            wb_sel_out     <= 2'b00;
        end
        else if (enable) begin
            // Pass execute-stage datapath values forward
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            imm32_out      <= imm32_in;
            rd_out         <= rd_in;

            // Pass execute-stage control signals forward
            reg_write_out  <= reg_write_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            wb_sel_out     <= wb_sel_in;
        end
    end

endmodule
