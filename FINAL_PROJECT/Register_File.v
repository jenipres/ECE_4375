`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5

Purpose:
This module implements the CPU register file. It contains 32 general-purpose
32-bit registers. The register file provides two asynchronous read ports
(busA and busB) and one synchronous write port (busD).

Register behavior:
- busA reads the register selected by busA_Addr.
- busB reads the register selected by busB_Addr.
- busD writes to the register selected by busD_Addr when load is high.
- R0 is hardwired to 0 and cannot be overwritten.
*/

module Register_File(
    input  wire        clk,
    input  wire        reset,
    input  wire        load,
    input  wire [31:0] busD,
    input  wire [4:0]  busA_Addr,
    input  wire [4:0]  busB_Addr,
    input  wire [4:0]  busD_Addr,
    output wire [31:0] busA,
    output wire [31:0] busB
);

    // ============================================================
    // Register Storage
    // ============================================================
    // RegFile[0] through RegFile[31] hold the CPU register values.
    // Each register is 32 bits wide.
    reg [31:0] RegFile [0:31];

    integer i;

    // ============================================================
    // Synchronous Reset and Writeback
    // ============================================================
    // On reset, all registers are cleared to 0.
    // During normal operation, the writeback stage writes busD into
    // busD_Addr when load is enabled.
    always @(posedge clk) begin
        if (reset) begin
            // Clear all 32 registers during reset
            for (i = 0; i < 32; i = i + 1)
                RegFile[i] <= 32'd0;
        end
        else begin
            // Keep R0 permanently equal to zero
            RegFile[0] <= 32'd0;

            // Write data into the selected destination register.
            // The check prevents R0 from being overwritten.
            if (load && (busD_Addr != 5'd0))
                RegFile[busD_Addr] <= busD;
        end
    end

    // ============================================================
    // Asynchronous Read Ports
    // ============================================================
    // The decode stage can read two source registers at the same time.
    // If either read address is R0, return 0 directly.
    assign busA = (busA_Addr == 5'd0) ? 32'd0 : RegFile[busA_Addr];
    assign busB = (busB_Addr == 5'd0) ? 32'd0 : RegFile[busB_Addr];

endmodule
