`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
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

    // Operation codes (what each instruction means)
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

    // ALU operations (what kind of math to do)
    localparam ALU_ADD  = 4'd0;
    localparam ALU_SUB  = 4'd1;
    localparam ALU_AND  = 4'd2;
    localparam ALU_OR   = 4'd3;
    localparam ALU_XOR  = 4'd4;
    localparam ALU_NOT  = 4'd5;
    localparam ALU_SHL  = 4'd6;
    localparam ALU_SHR  = 4'd7;
    localparam ALU_PASS = 4'd8;

    // Break the instruction into its parts
    assign rd       = instr[48:44];
    assign rs1      = instr[43:39];
    assign rs2      = instr[38:34];
    assign imm_mode = instr[33];
    assign imm28    = instr[32:5];
    assign opcode   = instr[4:0];

    always @(*) begin
        // Default: do nothing (safe state)
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

        // Decide what to do based on instruction
        case (opcode)

            OP_LD: begin
                reg_write   = 1'b1;
                alu_src_imm = 1'b1;
                alu_op      = ALU_PASS;
                wb_sel      = 2'b10; // write immediate value
            end

            OP_ST: begin
                mem_write   = 1'b1;
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD; // find memory address
                use_rs1     = 1'b1;
            end

            OP_ADD: begin
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_ADD;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_SUB: begin
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_SUB;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_AND: begin
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_AND;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_OR: begin
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_OR;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_XOR: begin
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_XOR;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_NOT: begin
                reg_write   = 1'b1;
                alu_op      = ALU_NOT;
                use_rs1     = 1'b1;
            end

            OP_SL: begin
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_SHL;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_SR: begin
                reg_write   = 1'b1;
                alu_src_imm = imm_mode;
                alu_op      = ALU_SHR;
                use_rs1     = 1'b1;
                use_rs2     = ~imm_mode;
            end

            OP_BZ: begin
                branch      = 1'b1;
                branch_type = 2'b01;
                use_rs1     = 1'b1;
            end

            OP_BNZ: begin
                branch      = 1'b1;
                branch_type = 2'b10;
                use_rs1     = 1'b1;
            end

            OP_BRA: begin
                branch      = 1'b1;
                branch_type = 2'b11;
            end

        endcase
    end

endmodule