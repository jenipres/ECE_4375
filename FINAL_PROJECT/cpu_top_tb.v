`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module cpu_top_tb;

    reg clk;
    reg reset;

    // Connect the CPU we are testing
    cpu_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock runs forever (10ns period)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Start with reset, then release it
    initial begin
        reset = 1'b1;
        #20;
        reset = 1'b0;
    end

    // Run simulation long enough to see pipeline behavior
    initial begin
        #1000;
        $finish;
    end

    integer cycle;
    initial cycle = 0;

    // Print useful info every clock cycle
    always @(posedge clk) begin
        if (reset) begin
            cycle <= 0;
            $display("==============================================================");
            $display("Reset active at time %0t", $time);
            $display("==============================================================");
        end
        else begin
            cycle <= cycle + 1;

            $display("\n==============================================================");
            $display("Cycle %0d   Time=%0t", cycle + 1, $time);
            $display("==============================================================");

            // Show what instruction is being fetched
            $display("IF STAGE");
            $display("  PC           = %0d (0x%08h)", DUT.pc, DUT.pc);
            $display("  instr_fetch  = 0x%013h", DUT.instr_fetch);

            // Show instruction moving through pipeline
            $display("IF/ID PIPE REG");
            $display("  if_id_pc     = %0d (0x%08h)", DUT.if_id_pc, DUT.if_id_pc);
            $display("  if_id_instr  = 0x%013h", DUT.if_id_instr);

            // Show decoded instruction and control signals
            $display("ID / DECODER");
            $display("  opcode       = 0x%02h", DUT.dec_opcode);
            $display("  rd           = R%0d", DUT.dec_rd);
            $display("  rs1          = R%0d", DUT.dec_rs1);
            $display("  rs2          = R%0d", DUT.dec_rs2);

            // Show register values being used
            $display("REGISTER FILE");
            $display("  rf_busA      = %0d (0x%08h)", DUT.rf_busA, DUT.rf_busA);
            $display("  rf_busB      = %0d (0x%08h)", DUT.rf_busB, DUT.rf_busB);

            // Show values entering execute stage
            $display("ID/EX PIPE REG");
            $display("  id_ex_pc         = %0d (0x%08h)", DUT.id_ex_pc, DUT.id_ex_pc);

            // Show ALU results and branch decisions
            $display("EX STAGE");
            $display("  alu_result   = %0d (0x%08h)", DUT.alu_result, DUT.alu_result);
            $display("  branch_taken = %0b", DUT.branch_taken);

            // Show results before writeback
            $display("EX/MEM/WB PIPE REG");
            $display("  ex_mem_alu_result = %0d (0x%08h)", DUT.ex_mem_alu_result, DUT.ex_mem_alu_result);

            // Show memory and final writeback value
            $display("MEM / WB");
            $display("  wb_data       = %0d (0x%08h)", DUT.wb_data, DUT.wb_data);

            // Quick check of key registers
            $display("REGISTER SNAPSHOT");
            $display("  R1  = %0d", DUT.RF.RegFile[1]);
            $display("  R2  = %0d", DUT.RF.RegFile[2]);
            $display("  R3  = %0d", DUT.RF.RegFile[3]);
            $display("  R11 = %0d", DUT.RF.RegFile[11]);
            $display("  RAM[20] = %0d", DUT.data_ram[20]);
        end
    end

endmodule