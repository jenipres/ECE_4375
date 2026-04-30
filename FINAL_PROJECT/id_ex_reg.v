`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module is the ID/EX pipeline register. It stores the decoded instruction
information from the decode stage and passes it into the execute stage on the
next clock edge.

This register carries:
- PC value for branch target calculation
- Register data read from the register file
- Sign-extended immediate value
- Source and destination register numbers
- Control signals needed by the ALU, branch unit, memory, and writeback logic

Pipeline role:
ID stage  ->  ID/EX register  ->  EX stage
*/

module id_ex_reg(
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        flush,

    // Datapath inputs from the decode stage
    input  wire [31:0] pc_in,
    input  wire [31:0] rs1_data_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] imm32_in,
    input  wire [4:0]  rd_in,
    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,

    // Control inputs from the decoder
    input  wire        reg_write_in,
    input  wire        mem_write_in,
    input  wire        mem_read_in,
    input  wire        alu_src_imm_in,
    input  wire [3:0]  alu_op_in,
    input  wire [1:0]  wb_sel_in,
    input  wire        branch_in,
    input  wire [1:0]  branch_type_in,
    input  wire        use_rs1_in,
    input  wire        use_rs2_in,

    // Registered datapath outputs to the execute stage
    output reg  [31:0] pc_out,
    output reg  [31:0] rs1_data_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] imm32_out,
    output reg  [4:0]  rd_out,
    output reg  [4:0]  rs1_out,
    output reg  [4:0]  rs2_out,

    // Registered control outputs to the execute stage
    output reg         reg_write_out,
    output reg         mem_write_out,
    output reg         mem_read_out,
    output reg         alu_src_imm_out,
    output reg  [3:0]  alu_op_out,
    output reg  [1:0]  wb_sel_out,
    output reg         branch_out,
    output reg  [1:0]  branch_type_out,
    output reg         use_rs1_out,
    output reg         use_rs2_out
);

    // ============================================================
    // Pipeline Register Update
    // ============================================================
    // reset:
    //   Clears all stored data and control signals.
    //
    // flush:
    //   Inserts a bubble/NOP into the execute stage. This prevents a stalled
    //   or incorrect instruction from changing registers, RAM, or the PC.
    //
    // enable:
    //   Allows the decoded instruction information to move into EX.
    always @(posedge clk) begin
        if (reset) begin
            // Clear datapath values
            pc_out           <= 32'd0;
            rs1_data_out     <= 32'd0;
            rs2_data_out     <= 32'd0;
            imm32_out        <= 32'd0;
            rd_out           <= 5'd0;
            rs1_out          <= 5'd0;
            rs2_out          <= 5'd0;

            // Clear control signals so the stage behaves like a NOP
            reg_write_out    <= 1'b0;
            mem_write_out    <= 1'b0;
            mem_read_out     <= 1'b0;
            alu_src_imm_out  <= 1'b0;
            alu_op_out       <= 4'd0;
            wb_sel_out       <= 2'b00;
            branch_out       <= 1'b0;
            branch_type_out  <= 2'b00;
            use_rs1_out      <= 1'b0;
            use_rs2_out      <= 1'b0;
        end
        else if (flush) begin
            // Clear datapath values when inserting a bubble
            pc_out           <= 32'd0;
            rs1_data_out     <= 32'd0;
            rs2_data_out     <= 32'd0;
            imm32_out        <= 32'd0;
            rd_out           <= 5'd0;
            rs1_out          <= 5'd0;
            rs2_out          <= 5'd0;

            // Disable all write, memory, branch, and hazard-use controls
            reg_write_out    <= 1'b0;
            mem_write_out    <= 1'b0;
            mem_read_out     <= 1'b0;
            alu_src_imm_out  <= 1'b0;
            alu_op_out       <= 4'd0;
            wb_sel_out       <= 2'b00;
            branch_out       <= 1'b0;
            branch_type_out  <= 2'b00;
            use_rs1_out      <= 1'b0;
            use_rs2_out      <= 1'b0;
        end
        else if (enable) begin
            // Pass datapath values into the execute stage
            pc_out           <= pc_in;
            rs1_data_out     <= rs1_data_in;
            rs2_data_out     <= rs2_data_in;
            imm32_out        <= imm32_in;
            rd_out           <= rd_in;
            rs1_out          <= rs1_in;
            rs2_out          <= rs2_in;

            // Pass control signals into the execute stage
            reg_write_out    <= reg_write_in;
            mem_write_out    <= mem_write_in;
            mem_read_out     <= mem_read_in;
            alu_src_imm_out  <= alu_src_imm_in;
            alu_op_out       <= alu_op_in;
            wb_sel_out       <= wb_sel_in;
            branch_out       <= branch_in;
            branch_type_out  <= branch_type_in;
            use_rs1_out      <= use_rs1_in;
            use_rs2_out      <= use_rs2_in;
        end
    end

endmodule
