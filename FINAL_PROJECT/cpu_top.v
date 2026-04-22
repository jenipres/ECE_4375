`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module cpu_top(
    input  wire clk,
    input  wire reset
);

    // Small memory so the CPU has instructions and data to run
    reg [48:0] instr_rom [0:63];
    reg [31:0] data_ram [0:255];

    integer i;

    initial begin
        // Clear memory at start
        for (i = 0; i < 64; i = i + 1)
            instr_rom[i] = 49'd0;

        for (i = 0; i < 256; i = i + 1)
            data_ram[i] = 32'd0;

        // Simple test program
        instr_rom[0]  = {5'd1,  5'd0,  5'd0, 1'b1, 28'd10,  5'h01}; // load 10
        instr_rom[1]  = {5'd2,  5'd0,  5'd0, 1'b1, 28'd5,   5'h01}; // load 5
        instr_rom[2]  = {5'd3,  5'd1,  5'd2, 1'b0, 28'd0,   5'h03}; // add
        instr_rom[3]  = {5'd4,  5'd3,  5'd0, 1'b1, 28'd7,   5'h03};
        instr_rom[4]  = {5'd5,  5'd4,  5'd0, 1'b1, 28'd1,   5'h04};
        instr_rom[5]  = {5'd6,  5'd4,  5'd5, 1'b0, 28'd0,   5'h05};
        instr_rom[6]  = {5'd7,  5'd6,  5'd0, 1'b1, 28'd3,   5'h06};
        instr_rom[7]  = {5'd8,  5'd7,  5'd1, 1'b0, 28'd0,   5'h07};
        instr_rom[8]  = {5'd9,  5'd8,  5'd0, 1'b0, 28'd0,   5'h08};
        instr_rom[9]  = {5'd10, 5'd9,  5'd0, 1'b1, 28'd2,   5'h09};
        instr_rom[10] = {5'd11, 5'd10, 5'd0, 1'b1, 28'd1,   5'h0A};
        instr_rom[11] = {5'd0,  5'd11, 5'd0, 1'b1, 28'd20,  5'h02};
        instr_rom[12] = {5'd0,  5'd0,  5'd0, 1'b1, 28'h0FFFFFFF, 5'h12}; // loop forever
    end

    // Tracks which instruction we are on
    reg [31:0] pc;

    // Fetch instruction from memory
    wire [48:0] instr_fetch;
    assign instr_fetch = instr_rom[pc[5:0]];

    // Pipeline: instruction moves from fetch to decode
    wire [31:0] if_id_pc;
    wire [48:0] if_id_instr;

    // Decoder breaks instruction into parts
    wire [4:0] dec_opcode, dec_rd, dec_rs1, dec_rs2;
    wire dec_imm_mode;
    wire [27:0] dec_imm28;

    // Control signals tell later stages what to do
    wire dec_reg_write, dec_mem_write, dec_mem_read;
    wire dec_alu_src_imm;
    wire [3:0] dec_alu_op;
    wire [1:0] dec_wb_sel;
    wire dec_branch;
    wire [1:0] dec_branch_type;
    wire dec_use_rs1, dec_use_rs2;

    // Values read from registers
    wire [31:0] rf_busA, rf_busB;
    wire [31:0] imm32;

    // Values moving into execute stage
    wire [31:0] id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm32;
    wire [4:0] id_ex_rd, id_ex_rs1, id_ex_rs2;

    // Control signals carried forward in pipeline
    wire id_ex_reg_write, id_ex_mem_write, id_ex_mem_read;
    wire id_ex_alu_src_imm;
    wire [3:0] id_ex_alu_op;
    wire [1:0] id_ex_wb_sel;
    wire id_ex_branch;
    wire [1:0] id_ex_branch_type;
    wire id_ex_use_rs1, id_ex_use_rs2;

    // Forwarding fixes cases where data isn't ready yet
    wire [31:0] ex_forward_value;
    wire forward_a, forward_b;

    wire [31:0] alu_a_in, alu_b_in;
    wire [31:0] branch_rs1_in;

    wire [31:0] alu_result;
    wire alu_zero;

    // Branch decides if we jump to a new instruction
    wire branch_taken;
    wire [31:0] branch_target;

    // Final stage before writeback
    wire [31:0] ex_mem_alu_result, ex_mem_rs2_data, ex_mem_imm32;
    wire [4:0] ex_mem_rd;

    wire ex_mem_reg_write, ex_mem_mem_write, ex_mem_mem_read;
    wire [1:0] ex_mem_wb_sel;

    // Value that gets written back to registers
    reg [31:0] mem_read_data;
    reg [31:0] wb_data;

    // Stall pauses pipeline if data is not ready
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

    wire pipe_enable = ~stall;
    wire if_flush = branch_taken;
    wire id_flush = branch_taken | stall;

    // Update PC every clock
    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else if (branch_taken)
            pc <= branch_target;
        else if (!stall)
            pc <= pc + 32'd1;
    end

    // Holds instruction between fetch and decode
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

    // Turns instruction into control signals
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

    // Register file stores values for instructions
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

    // Extends smaller immediate into full 32-bit value
    imm_extend IMM_EXT (
        .imm28(dec_imm28),
        .imm32(imm32)
    );

    // Holds values before execute stage
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

    // Choose correct values for ALU (forward if needed)
    assign ex_forward_value = wb_data;
    assign alu_a_in = forward_a ? ex_forward_value : id_ex_rs1_data;
    assign alu_b_in = id_ex_alu_src_imm ? id_ex_imm32 :
                      (forward_b ? ex_forward_value : id_ex_rs2_data);
    assign branch_rs1_in = forward_a ? ex_forward_value : id_ex_rs1_data;

    // ALU does math
    alu32 ALU (
        .a(alu_a_in),
        .b(alu_b_in),
        .alu_op(id_ex_alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Handles jumps
    branch_unit BRANCH (
        .pc_current(id_ex_pc),
        .rs1_value(branch_rs1_in),
        .imm32(id_ex_imm32),
        .branch(id_ex_branch),
        .branch_type(id_ex_branch_type),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );
    
    // EX/MEM/WB pipeline register
    ex_mem_wb_reg EX_MEM_WB (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .flush(1'b0),

        .alu_result_in(alu_result),
        .rs2_data_in(id_ex_rs2_data),
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

    // Memory read/write
    always @(posedge clk) begin
        if (ex_mem_mem_write)
            data_ram[ex_mem_alu_result[7:0]] <= ex_mem_rs2_data;

        mem_read_data <= data_ram[ex_mem_alu_result[7:0]];
    end

    // Pick what gets written back
    always @(*) begin
        case (ex_mem_wb_sel)
            2'b00: wb_data = ex_mem_alu_result;
            2'b01: wb_data = mem_read_data;
            2'b10: wb_data = ex_mem_imm32;
            default: wb_data = 32'd0;
        endcase
    end

endmodule