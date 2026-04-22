`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
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

    // Stores 32 registers
    reg [31:0] RegFile [0:31];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            // Clear all registers
            for (i = 0; i < 32; i = i + 1)
                RegFile[i] <= 32'd0;
        end
        else begin
            // R0 is always 0
            RegFile[0] <= 32'd0;

            // Write data into register if enabled
            if (load && (busD_Addr != 5'd0))
                RegFile[busD_Addr] <= busD;
        end
    end

    // Read values from registers
    assign busA = (busA_Addr == 5'd0) ? 32'd0 : RegFile[busA_Addr];
    assign busB = (busB_Addr == 5'd0) ? 32'd0 : RegFile[busB_Addr];

endmodule