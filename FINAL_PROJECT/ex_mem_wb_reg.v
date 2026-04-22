`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module ex_mem_wb_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        flush,

    // Datapath inputs
    input  wire [31:0] alu_result_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] imm32_in,
    input  wire [4:0]  rd_in,

    // Control inputs
    input  wire        reg_write_in,
    input  wire        mem_write_in,
    input  wire        mem_read_in,
    input  wire [1:0]  wb_sel_in,

    // Registered outputs
    output reg  [31:0] alu_result_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] imm32_out,
    output reg  [4:0]  rd_out,

    output reg         reg_write_out,
    output reg         mem_write_out,
    output reg         mem_read_out,
    output reg  [1:0]  wb_sel_out
);

    always @(posedge clk) begin
        if (reset) begin
            alu_result_out <= 32'd0;
            rs2_data_out   <= 32'd0;
            imm32_out      <= 32'd0;
            rd_out         <= 5'd0;

            reg_write_out  <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            wb_sel_out     <= 2'b00;
        end
        else if (flush) begin
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
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            imm32_out      <= imm32_in;
            rd_out         <= rd_in;

            reg_write_out  <= reg_write_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            wb_sel_out     <= wb_sel_in;
        end
    end

endmodule