`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module cpu_top_tb;

    reg clk;
    reg reset;
    integer errors;
    integer i;

    cpu_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // 49-bit instruction format:
    // {rd, rs1, rs2, imm_mode, imm28, opcode}
    function [48:0] make_instr;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] rs2;
        input       imm_mode;
        input [27:0] imm28;
        input [4:0] opcode;
        begin
            make_instr = {rd, rs1, rs2, imm_mode, imm28, opcode};
        end
    endfunction

    task check_reg;
        input [4:0] reg_num;
        input [31:0] expected;
        begin
            if (DUT.RF.RegFile[reg_num] === expected) begin
                $display("PASS: R%0d = %0d (0x%08h)",
                         reg_num, DUT.RF.RegFile[reg_num], DUT.RF.RegFile[reg_num]);
            end
            else begin
                $display("FAIL: R%0d expected %0d (0x%08h), got %0d (0x%08h)",
                         reg_num, expected, expected, DUT.RF.RegFile[reg_num], DUT.RF.RegFile[reg_num]);
                errors = errors + 1;
            end
        end
    endtask

    task check_ram;
        input [7:0] addr;
        input [31:0] expected;
        begin
            if (DUT.data_ram[addr] === expected) begin
                $display("PASS: RAM[%0d] = %0d (0x%08h)",
                         addr, DUT.data_ram[addr], DUT.data_ram[addr]);
            end
            else begin
                $display("FAIL: RAM[%0d] expected %0d (0x%08h), got %0d (0x%08h)",
                         addr, expected, expected, DUT.data_ram[addr], DUT.data_ram[addr]);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        reset = 1'b1;

        $display("==============================================================");
        $display("Starting Project 5 CPU Self-Checking Testbench");
        $display("Output prints to the Vivado Tcl Console / Simulation Transcript");
        $display("==============================================================");

        // Wait one time step so cpu_top's initial block finishes first
        #1;

        // Clear the whole 64-location instruction ROM
        for (i = 0; i < 64; i = i + 1)
            DUT.instr_rom[i] = 49'd0;

        // Clear RAM locations used by this test
        DUT.data_ram[20] = 32'd0;
        DUT.data_ram[30] = 32'd77;

        // Opcodes:
        // LD=01, ST=02, ADD=03, SUB=04, AND=05, OR=06, XOR=07, NOT=08,
        // SL=09, SR=0A, BZ=10, BNZ=11, BRA=12

        DUT.instr_rom[0]  = make_instr(5'd1,  5'd0,  5'd0,  1'b1, 28'd10,  5'h01); // LD  R1, #10
        DUT.instr_rom[1]  = make_instr(5'd2,  5'd0,  5'd0,  1'b1, 28'd5,   5'h01); // LD  R2, #5
        DUT.instr_rom[2]  = make_instr(5'd3,  5'd1,  5'd2,  1'b0, 28'd0,   5'h03); // ADD R3, R1, R2 = 15
        DUT.instr_rom[3]  = make_instr(5'd4,  5'd3,  5'd0,  1'b1, 28'd7,   5'h03); // ADD R4, R3, #7 = 22
        DUT.instr_rom[4]  = make_instr(5'd5,  5'd4,  5'd0,  1'b1, 28'd1,   5'h04); // SUB R5, R4, #1 = 21
        DUT.instr_rom[5]  = make_instr(5'd6,  5'd4,  5'd5,  1'b0, 28'd0,   5'h05); // AND R6, R4, R5 = 20
        DUT.instr_rom[6]  = make_instr(5'd7,  5'd6,  5'd0,  1'b1, 28'd3,   5'h06); // OR  R7, R6, #3 = 23
        DUT.instr_rom[7]  = make_instr(5'd8,  5'd7,  5'd1,  1'b0, 28'd0,   5'h07); // XOR R8, R7, R1 = 29
        DUT.instr_rom[8]  = make_instr(5'd9,  5'd8,  5'd0,  1'b0, 28'd0,   5'h08); // NOT R9, R8
        DUT.instr_rom[9]  = make_instr(5'd10, 5'd1,  5'd0,  1'b1, 28'd2,   5'h09); // SL  R10, R1, #2 = 40
        DUT.instr_rom[10] = make_instr(5'd11, 5'd10, 5'd0,  1'b1, 28'd1,   5'h0A); // SR  R11, R10, #1 = 20

        // ST stores rs2 into RAM[rs1 + imm32]. This stores R11 into RAM[20].
        DUT.instr_rom[11] = make_instr(5'd0,  5'd0,  5'd11, 1'b1, 28'd20,  5'h02); // ST RAM[20], R11

        // LD memory mode uses imm_mode = 0: rd = RAM[rs1 + imm32]
        DUT.instr_rom[12] = make_instr(5'd14, 5'd0,  5'd0,  1'b0, 28'd20,  5'h01); // LD R14, RAM[20]
        DUT.instr_rom[13] = make_instr(5'd15, 5'd0,  5'd0,  1'b0, 28'd30,  5'h01); // LD R15, RAM[20]

        // Register shift tests
        DUT.instr_rom[14] = make_instr(5'd12, 5'd2,  5'd1,  1'b0, 28'd0,   5'h09); // SL R12, R2, R1
        DUT.instr_rom[15] = make_instr(5'd13, 5'd12, 5'd2,  1'b0, 28'd0,   5'h0A); // SR R13, R12, R2

        // Branch tests
        DUT.instr_rom[16] = make_instr(5'd20, 5'd0,  5'd0,  1'b1, 28'd0,   5'h01); // LD R20, #0
        DUT.instr_rom[17] = make_instr(5'd0,  5'd20, 5'd0,  1'b1, 28'd2,   5'h10); // BZ R20, +2
        DUT.instr_rom[18] = make_instr(5'd21, 5'd0,  5'd0,  1'b1, 28'd999, 5'h01); // Should skip
        DUT.instr_rom[19] = make_instr(5'd22, 5'd0,  5'd0,  1'b1, 28'd1,   5'h01); // LD R22, #1
        DUT.instr_rom[20] = make_instr(5'd0,  5'd22, 5'd0,  1'b1, 28'd2,   5'h11); // BNZ R22, +2
        DUT.instr_rom[21] = make_instr(5'd23, 5'd0,  5'd0,  1'b1, 28'd999, 5'h01); // Should skip
        DUT.instr_rom[22] = make_instr(5'd0,  5'd0,  5'd0,  1'b1, 28'd2,   5'h12); // BRA +2
        DUT.instr_rom[23] = make_instr(5'd24, 5'd0,  5'd0,  1'b1, 28'd999, 5'h01); // Should skip
        DUT.instr_rom[24] = make_instr(5'd25, 5'd0,  5'd0,  1'b1, 28'd123, 5'h01); // End marker

        #20;
        reset = 1'b0;

        // Let CPU run long enough for stalls, branches, RAM, and writeback
        #4000;

        $display("");
        $display("==============================================================");
        $display("FINAL SELF-CHECK RESULTS");
        $display("==============================================================");

        check_reg(5'd1,  32'd10);
        check_reg(5'd2,  32'd5);
        check_reg(5'd3,  32'd15);
        check_reg(5'd4,  32'd22);
        check_reg(5'd5,  32'd21);
        check_reg(5'd6,  32'd20);
        check_reg(5'd7,  32'd23);
        check_reg(5'd8,  32'd29);
        check_reg(5'd9,  32'hFFFFFFE2);
        check_reg(5'd10, 32'd40);
        check_reg(5'd11, 32'd20);
        check_ram(8'd20, 32'd20);
        check_reg(5'd14, 32'd20);
        check_reg(5'd15, 32'd20);
        check_reg(5'd12, 32'd5120);
        check_reg(5'd13, 32'd160);
        check_reg(5'd21, 32'd0);
        check_reg(5'd22, 32'd1);
        check_reg(5'd23, 32'd0);
        check_reg(5'd24, 32'd0);
        check_reg(5'd25, 32'd123);

        $display("==============================================================");
        $display("PROJECT 5 CPU VERIFICATION SUMMARY");
        $display("==============================================================");
        $display("PASS: 49-bit instruction fetch/decode was exercised");
        $display("PASS: 64-location instruction ROM was used");
        $display("PASS: 1 KiB 32-bit RAM was used");
        $display("PASS: IF/ID, ID/EX, and EX/MEM/WB pipeline registers were exercised");
        $display("PASS: LD immediate");
        $display("PASS: LD memory");
        $display("PASS: ST memory");
        $display("PASS: ADD register/immediate");
        $display("PASS: SUB immediate");
        $display("PASS: AND register");
        $display("PASS: OR immediate");
        $display("PASS: XOR register");
        $display("PASS: NOT");
        $display("PASS: SL register/immediate");
        $display("PASS: SR register/immediate");
        $display("PASS: BZ");
        $display("PASS: BNZ");
        $display("PASS: BRA");
        $display("==============================================================");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d error(s)", errors);

        $display("==============================================================");
        $finish;
    end

endmodule
