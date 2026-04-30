`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module decodes the 49-bit instruction format used by the Project 5 CPU.
It extracts the register fields, immediate field, opcode, and generates the
control signals needed by the datapath.

Instruction format:
{rd[4:0], rs1[4:0], rs2[4:0], imm_mode, imm28[27:0], opcode[4:0]}

Supported instructions:
LD, ST, ADD, SUB, AND, OR, XOR, NOT, SL, SR, BZ, BNZ, BRA

Important control outputs:
reg_write   - enables register file writeback
mem_write   - enables RAM write for ST
mem_read    - selects RAM data for LD memory
alu_src_imm - selects immediate instead of rs2 for ALU input B
wb_sel      - chooses ALU result, RAM data, or immediate for writeback
branch      - enables branch decision logic
use_rs1/2   - tells hazard unit which source registers are actually used
*/

module instruction_decoder_49(
    input  wire [48:0] instr,

    output wire [4:0]  opcode,
    output wire [4:0]  rd,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire        imm_mode,
    output wire [27:0] imm28,

    output reg         reg_write,
    output reg         mem_write,
    output reg         mem_read,
    output reg         alu_src_imm,
    output reg  [3:0]  alu_op,
    output reg  [1:0]  wb_sel,       
    output reg         branch,
    output reg  [1:0]  branch_type,  
    output reg         use_rs1,
    output reg         use_rs2
);

    // ============================================================
    // Opcode Values
    // ============================================================
    // These are the 5-bit opcodes required by the project handout.
    localparam OP_LD  = 5'h01;
    localparam OP_ST  = 5'h02;
    localparam OP_ADD = 5'h03;
    localparam OP_SUB = 5'h04;
    localparam OP_AND = 5'h05;
    localparam OP_OR  = 5'h06;
    localparam OP_XOR = 5'h07;
    localparam OP_NOT = 5'h08;
    localparam OP_SL  = 5'h09;
    localparam OP_SR  = 5'h0A;
    localparam OP_BZ  = 5'h10;
    localparam OP_BNZ = 5'h11;
    localparam OP_BRA = 5'h12;

    // ============================================================
    // ALU Operation Codes
    // ============================================================
    // These local parameters tell the ALU which operation to perform.
    localparam ALU_ADD  = 4'd0;
    localparam ALU_SUB  = 4'd1;
    localparam ALU_AND  = 4'd2;
    localparam ALU_OR   = 4'd3;
    localparam ALU_XOR  = 4'd4;
    localparam ALU_NOT  = 4'd5;
    localparam ALU_SHL  = 4'd6;
    localparam ALU_SHR  = 4'd7;
    localparam ALU_PASS = 4'd8;

    // ============================================================
    // Instruction Field Extraction
    // ============================================================
    // The CPU uses one fixed 49-bit instruction format.
    assign rd       = instr[48:44];
    assign rs1      = instr[43:39];
    assign rs2      = instr[38:34];
    assign imm_mode = instr[33];
    assign imm28    = instr[32:5];
    assign opcode   = instr[4:0];

    // ============================================================
    // Control Signal Generation
    // ============================================================
    // The decoder is combinational. Each instruction sets the datapath
    // controls needed by later pipeline stages. Defaults make unknown
    // opcodes behave like NOPs.
    always @(*) begin
        // Default control values: NOP / do nothing
        reg_write   = 1'b0;
        mem_write   = 1'b0;
        mem_read    = 1'b0;
        alu_src_imm = 1'b0;
        alu_op      = ALU_ADD;
        wb_sel      = 2'b00;
        branch      = 1'b0;
        branch_type = 2'b00;
        use_rs1     = 1'b0;
        use_rs2     = 1'b0;

        case (opcode)

            OP_LD: begin
                // LD supports two modes:
                // imm_mode = 1: rd = immediate
                // imm_mode = 0: rd = RAM[rs1 + immediate]
                reg_write   = 1'b1;
                alu_src_imm = 1'b1;
                use_rs1     = ~imm_mode;

                if (imm_mode) begin
                    // Immediate load: write imm32 directly into rd
                    mem_read = 1'b0;
                    alu_op   = ALU_PASS;
                    wb_sel   = 2'b10;
                end
                else begin
                    // Memory load: ALU calculates address, RAM data writes to rd
                    mem_read = 1'b1;
                    alu_op   = ALU_ADD;
                    wb_sel   = 2'b01;
                end
            end

            OP_ST: begin
                // Store: RAM[rs1 + immediate] = rs2
                // rs1 is the base address register and rs2 is the data source.
                mem_write   = 1'b1;
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD;
                use_rs1     = 1'b1;
                use_rs2     = 1'b1;
            end

            OP_ADD: begin
                // Add register or immediate
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_ADD;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_SUB: begin
                // Subtract register or immediate
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_SUB;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_AND: begin
                // Bitwise AND register or immediate
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_AND;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_OR: begin
                // Bitwise OR register or immediate
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_OR;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_XOR: begin
                // Bitwise XOR register or immediate
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_XOR;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_NOT: begin
                // Bitwise NOT uses only rs1
                reg_write   = 1'b1;
                alu_op      = ALU_NOT;
                use_rs1     = 1'b1;
            end

            OP_SL: begin
                // Shift left register or immediate
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_SHL;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_SR: begin
                // Shift right register or immediate
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_SHR;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_BZ: begin
                // Branch if rs1 is zero
                branch      = 1'b1;
                branch_type = 2'b01;
                use_rs1     = 1'b1;
            end

            OP_BNZ: begin
                // Branch if rs1 is not zero
                branch      = 1'b1;
                branch_type = 2'b10;
                use_rs1     = 1'b1;
            end

            OP_BRA: begin
                // Unconditional branch
                branch      = 1'b1;
                branch_type = 2'b11;
            end

            default: begin
                // Unknown opcode acts as NOP.
                // The default values above already do this, but this case
                // removes incomplete-case warnings during synthesis.
                reg_write   = 1'b0;
                mem_write   = 1'b0;
                mem_read    = 1'b0;
                alu_src_imm = 1'b0;
                alu_op      = ALU_ADD;
                wb_sel      = 2'b00;
                branch      = 1'b0;
                branch_type = 2'b00;
                use_rs1     = 1'b0;
                use_rs2     = 1'b0;
            end

        endcase
    end

endmodule
