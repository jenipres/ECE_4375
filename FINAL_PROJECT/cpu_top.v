`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This is the top-level module for the Project 5 pipelined CPU. It connects
the instruction ROM, data RAM, register file, instruction decoder, pipeline
registers, ALU, branch unit, hazard unit, forwarding unit, and writeback mux.

Pipeline stages:
IF      - Program counter and instruction fetch from ROM
ID      - Instruction decode, register read, immediate extension, hazard check
EX      - ALU operation, branch decision, and forwarding
MEM/WB  - Data memory access and register writeback

Instruction format:
{rd[4:0], rs1[4:0], rs2[4:0], imm_mode, imm28[27:0], opcode[4:0]}

Memory sizes:
Instruction ROM: 64 locations x 49 bits
Data RAM:        256 locations x 32 bits = 1 KiB
*/

module cpu_top(
    input  wire clk,
    input  wire reset
);

    // ============================================================
    // Instruction ROM and Data RAM
    // ============================================================
    // The instruction ROM holds 64 49-bit instructions.
    // The data RAM holds 256 32-bit words, giving a total size of 1 KiB.
    reg [48:0] instr_rom [0:63];
    reg [31:0] data_ram [0:255];

    integer i;

    initial begin
        // Clear instruction ROM before loading the program
        for (i = 0; i < 64; i = i + 1)
            instr_rom[i] = 49'd0;

        // Clear all RAM locations at startup
        for (i = 0; i < 256; i = i + 1)
            data_ram[i] = 32'd0;

        // ========================================================
        // Built-in program used for basic CPU operation
        // ========================================================
        // These instructions exercise immediate loads, ALU operations,
        // shifts, a store to memory, and a final branch loop.
        instr_rom[0]  = {5'd1,  5'd0,  5'd0,  1'b1, 28'd10,  5'h01}; // LD  R1, #10
        instr_rom[1]  = {5'd2,  5'd0,  5'd0,  1'b1, 28'd5,   5'h01}; // LD  R2, #5
        instr_rom[2]  = {5'd3,  5'd1,  5'd2,  1'b0, 28'd0,   5'h03}; // ADD R3, R1, R2
        instr_rom[3]  = {5'd4,  5'd3,  5'd0,  1'b1, 28'd7,   5'h03}; // ADD R4, R3, #7
        instr_rom[4]  = {5'd5,  5'd4,  5'd0,  1'b1, 28'd1,   5'h04}; // SUB R5, R4, #1
        instr_rom[5]  = {5'd6,  5'd4,  5'd5,  1'b0, 28'd0,   5'h05}; // AND R6, R4, R5
        instr_rom[6]  = {5'd7,  5'd6,  5'd0,  1'b1, 28'd3,   5'h06}; // OR  R7, R6, #3
        instr_rom[7]  = {5'd8,  5'd7,  5'd1,  1'b0, 28'd0,   5'h07}; // XOR R8, R7, R1
        instr_rom[8]  = {5'd9,  5'd8,  5'd0,  1'b0, 28'd0,   5'h08}; // NOT R9, R8

        // Shift instructions:
        // R10 = R1 << 2 = 40
        // R11 = R10 >> 1 = 20
        instr_rom[9]  = {5'd10, 5'd1,  5'd0,  1'b1, 28'd2,   5'h09}; // SL  R10, R1, #2
        instr_rom[10] = {5'd11, 5'd10, 5'd0,  1'b1, 28'd1,   5'h0A}; // SR  R11, R10, #1

        // Store R11 into RAM[20].
        // ST format used here: RAM[rs1 + imm] = rs2
        // rs1 = R0, rs2 = R11, imm = 20
        instr_rom[11] = {5'd0,  5'd0,  5'd11, 1'b1, 28'd20,  5'h02}; // ST RAM[20], R11

        // Branch forever to keep the processor from running into random code
        instr_rom[12] = {5'd0,  5'd0,  5'd0,  1'b1, 28'h0FFFFFFF, 5'h12}; // BRA -1
    end

    // ============================================================
    // IF Stage Signals
    // ============================================================

    // Program counter tracks the current instruction address
    reg [31:0] pc;

    // Fetch instruction from the 64-location ROM.
    // Only pc[5:0] is used because the ROM has 64 entries.
    wire [48:0] instr_fetch;
    assign instr_fetch = instr_rom[pc[5:0]];

    // IF/ID pipeline register outputs
    wire [31:0] if_id_pc;
    wire [48:0] if_id_instr;

    // ============================================================
    // ID Stage Signals
    // ============================================================

    // Decoded instruction fields
    wire [4:0] dec_opcode, dec_rd, dec_rs1, dec_rs2;
    wire dec_imm_mode;
    wire [27:0] dec_imm28;

    // Control signals produced by the decoder
    wire dec_reg_write, dec_mem_write, dec_mem_read;
    wire dec_alu_src_imm;
    wire [3:0] dec_alu_op;
    wire [1:0] dec_wb_sel;
    wire dec_branch;
    wire [1:0] dec_branch_type;
    wire dec_use_rs1, dec_use_rs2;

    // Register file read data and sign-extended immediate
    wire [31:0] rf_busA, rf_busB;
    wire [31:0] imm32;

    // ============================================================
    // ID/EX Pipeline Register Signals
    // ============================================================

    // Data values passed into the execute stage
    wire [31:0] id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm32;
    wire [4:0] id_ex_rd, id_ex_rs1, id_ex_rs2;

    // Control signals carried into the execute stage
    wire id_ex_reg_write, id_ex_mem_write, id_ex_mem_read;
    wire id_ex_alu_src_imm;
    wire [3:0] id_ex_alu_op;
    wire [1:0] id_ex_wb_sel;
    wire id_ex_branch;
    wire [1:0] id_ex_branch_type;
    wire id_ex_use_rs1, id_ex_use_rs2;

    // ============================================================
    // EX Stage Signals
    // ============================================================

    // Forwarding signals are used to handle data hazards without waiting
    // for values to fully write back into the register file.
    wire [31:0] ex_forward_value;
    wire forward_a, forward_b;

    // ALU inputs and branch/store forwarded values
    wire [31:0] alu_a_in, alu_b_in;
    wire [31:0] branch_rs1_in;
    wire [31:0] store_data_in;

    // ALU output
    wire [31:0] alu_result;
    wire alu_zero;

    // Branch control
    wire branch_taken;
    wire [31:0] branch_target;

    // ============================================================
    // EX/MEM/WB Pipeline Register Signals
    // ============================================================

    // Data carried to memory/writeback stage
    wire [31:0] ex_mem_alu_result, ex_mem_rs2_data, ex_mem_imm32;
    wire [4:0] ex_mem_rd;

    // Control carried to memory/writeback stage
    wire ex_mem_reg_write, ex_mem_mem_write, ex_mem_mem_read;
    wire [1:0] ex_mem_wb_sel;

    // RAM read data and final writeback data
    reg [31:0] mem_read_data;
    reg [31:0] wb_data;

    // ============================================================
    // Hazard and Pipeline Control
    // ============================================================

    // Stall is asserted when the next instruction needs data that is not ready
    wire stall;

    hazard_unit HAZARD (
        .dec_rs1(dec_rs1),
        .dec_rs2(dec_rs2),
        .dec_use_rs1(dec_use_rs1),
        .dec_use_rs2(dec_use_rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_reg_write(id_ex_reg_write),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .stall(stall)
    );

    forwarding_unit FWD (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Pipeline control:
    // pipe_enable pauses IF/ID and ID/EX during a stall.
    // if_flush removes fetched instructions after a branch.
    // id_flush inserts a bubble on branch or stall.
    wire pipe_enable = ~stall;
    wire if_flush = branch_taken;
    wire id_flush = branch_taken | stall;

    // ============================================================
    // Program Counter Update Logic
    // ============================================================

    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else if (branch_taken)
            pc <= branch_target;
        else if (!stall)
            pc <= pc + 32'd1;
    end

    // ============================================================
    // IF/ID Pipeline Register
    // ============================================================
    // Holds the fetched instruction and PC between IF and ID.
    if_id_reg IF_ID (
        .clk(clk),
        .reset(reset),
        .enable(pipe_enable),
        .flush(if_flush),
        .pc_in(pc),
        .instr_in(instr_fetch),
        .pc_out(if_id_pc),
        .instr_out(if_id_instr)
    );

    // ============================================================
    // Instruction Decoder
    // ============================================================
    // Converts the 49-bit instruction into register fields, immediate
    // field, opcode, and datapath control signals.
    instruction_decoder_49 DECODER (
        .instr(if_id_instr),
        .opcode(dec_opcode),
        .rd(dec_rd),
        .rs1(dec_rs1),
        .rs2(dec_rs2),
        .imm_mode(dec_imm_mode),
        .imm28(dec_imm28),
        .reg_write(dec_reg_write),
        .mem_write(dec_mem_write),
        .mem_read(dec_mem_read),
        .alu_src_imm(dec_alu_src_imm),
        .alu_op(dec_alu_op),
        .wb_sel(dec_wb_sel),
        .branch(dec_branch),
        .branch_type(dec_branch_type),
        .use_rs1(dec_use_rs1),
        .use_rs2(dec_use_rs2)
    );

    // ============================================================
    // Register File
    // ============================================================
    // Reads rs1 and rs2 during decode and writes wb_data during writeback.
    Register_File RF (
        .clk(clk),
        .reset(reset),
        .load(ex_mem_reg_write),
        .busD(wb_data),
        .busA_Addr(dec_rs1),
        .busB_Addr(dec_rs2),
        .busD_Addr(ex_mem_rd),
        .busA(rf_busA),
        .busB(rf_busB)
    );

    // ============================================================
    // Immediate Extension
    // ============================================================
    // Extends the 28-bit immediate field to 32 bits for ALU, memory,
    // and branch target calculations.
    imm_extend IMM_EXT (
        .imm28(dec_imm28),
        .imm32(imm32)
    );

    // ============================================================
    // ID/EX Pipeline Register
    // ============================================================
    // Stores decoded register data, immediate data, register numbers,
    // and control signals before the execute stage.
    id_ex_reg ID_EX (
        .clk(clk),
        .reset(reset),
        .enable(pipe_enable),
        .flush(id_flush),

        .pc_in(if_id_pc),
        .rs1_data_in(rf_busA),
        .rs2_data_in(rf_busB),
        .imm32_in(imm32),
        .rd_in(dec_rd),
        .rs1_in(dec_rs1),
        .rs2_in(dec_rs2),

        .reg_write_in(dec_reg_write),
        .mem_write_in(dec_mem_write),
        .mem_read_in(dec_mem_read),
        .alu_src_imm_in(dec_alu_src_imm),
        .alu_op_in(dec_alu_op),
        .wb_sel_in(dec_wb_sel),
        .branch_in(dec_branch),
        .branch_type_in(dec_branch_type),
        .use_rs1_in(dec_use_rs1),
        .use_rs2_in(dec_use_rs2),

        .pc_out(id_ex_pc),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .imm32_out(id_ex_imm32),
        .rd_out(id_ex_rd),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),

        .reg_write_out(id_ex_reg_write),
        .mem_write_out(id_ex_mem_write),
        .mem_read_out(id_ex_mem_read),
        .alu_src_imm_out(id_ex_alu_src_imm),
        .alu_op_out(id_ex_alu_op),
        .wb_sel_out(id_ex_wb_sel),
        .branch_out(id_ex_branch),
        .branch_type_out(id_ex_branch_type),
        .use_rs1_out(id_ex_use_rs1),
        .use_rs2_out(id_ex_use_rs2)
    );

    // ============================================================
    // Forwarding and ALU Input Selection
    // ============================================================

    // The value available for forwarding is the current writeback value.
    assign ex_forward_value = wb_data;

    // Forward operand A if the previous instruction is writing to rs1.
    assign alu_a_in = forward_a ? ex_forward_value : id_ex_rs1_data;

    // Operand B can come from the immediate, forwarded data, or rs2 data.
    assign alu_b_in = id_ex_alu_src_imm ? id_ex_imm32 :
                      (forward_b ? ex_forward_value : id_ex_rs2_data);

    // Branch comparisons also need forwarded rs1 data when required.
    assign branch_rs1_in = forward_a ? ex_forward_value : id_ex_rs1_data;

    // Store instructions need the forwarded rs2 value so the correct data
    // is written to RAM even if the value was just produced.
    assign store_data_in = forward_b ? ex_forward_value : id_ex_rs2_data;

    // ============================================================
    // ALU
    // ============================================================
    // Performs arithmetic, logic, shift, NOT, and pass-through operations.
    alu32 ALU (
        .a(alu_a_in),
        .b(alu_b_in),
        .alu_op(id_ex_alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // ============================================================
    // Branch Unit
    // ============================================================
    // Calculates branch target and determines if BZ, BNZ, or BRA is taken.
    branch_unit BRANCH (
        .pc_current(id_ex_pc),
        .rs1_value(branch_rs1_in),
        .imm32(id_ex_imm32),
        .branch(id_ex_branch),
        .branch_type(id_ex_branch_type),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    // ============================================================
    // EX/MEM/WB Pipeline Register
    // ============================================================
    // Carries the ALU result, store data, immediate, destination register,
    // and memory/writeback control signals into the final pipeline stage.
    ex_mem_wb_reg EX_MEM_WB (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .flush(1'b0),

        .alu_result_in(alu_result),
        .rs2_data_in(store_data_in),
        .imm32_in(id_ex_imm32),
        .rd_in(id_ex_rd),

        .reg_write_in(id_ex_reg_write),
        .mem_write_in(id_ex_mem_write),
        .mem_read_in(id_ex_mem_read),
        .wb_sel_in(id_ex_wb_sel),

        .alu_result_out(ex_mem_alu_result),
        .rs2_data_out(ex_mem_rs2_data),
        .imm32_out(ex_mem_imm32),
        .rd_out(ex_mem_rd),

        .reg_write_out(ex_mem_reg_write),
        .mem_write_out(ex_mem_mem_write),
        .mem_read_out(ex_mem_mem_read),
        .wb_sel_out(ex_mem_wb_sel)
    );

    // ============================================================
    // Data RAM Access
    // ============================================================
    // Store instructions write rs2 data into RAM.
    // Load instructions read RAM data using the ALU result as the address.
    always @(posedge clk) begin
        if (ex_mem_mem_write)
            data_ram[ex_mem_alu_result[7:0]] <= ex_mem_rs2_data;

        mem_read_data <= data_ram[ex_mem_alu_result[7:0]];
    end

    // ============================================================
    // Writeback Mux
    // ============================================================
    // Selects the value that will be written back into the register file.
    //
    // wb_sel:
    // 00 = ALU result
    // 01 = RAM read data
    // 10 = immediate value
    always @(*) begin
        case (ex_mem_wb_sel)
            2'b00: wb_data = ex_mem_alu_result;
            2'b01: wb_data = mem_read_data;
            2'b10: wb_data = ex_mem_imm32;
            default: wb_data = 32'd0;
        endcase
    end

endmodule
