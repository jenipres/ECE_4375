`timescale 1ns / 1ps
/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 5
*/

module branch_unit(
    input  wire [31:0] pc_current,
    input  wire [31:0] rs1_value,
    input  wire [31:0] imm32,
    input  wire        branch,
    input  wire [1:0]  branch_type,   
    output reg         branch_taken,
    output wire [31:0] branch_target
);

    // Compute where to jump (PC + offset)
    assign branch_target = pc_current + imm32;

    // Decide if the branch should happen
    always @(*) begin
        branch_taken = 1'b0;

        if (branch) begin
            case (branch_type)
                2'b01: branch_taken = (rs1_value == 32'd0); // branch if zero
                2'b10: branch_taken = (rs1_value != 32'd0); // branch if not zero
                2'b11: branch_taken = 1'b1;                 // always branch
                default: branch_taken = 1'b0;
            endcase
        end
    end

endmodule