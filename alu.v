/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 3
*/
module alu (
    input  wire [31:0] busA,
    input  wire [31:0] busB,
    input  wire [4:0]  ALUOp,

    output reg  [31:0] result,
    output wire        z,
    output wire        n,
    output reg         c,
    output reg         v
);

    // Required opcode values from project sheet
    localparam LD  = 5'h01;
    localparam ADD = 5'h03;
    localparam SUB = 5'h04;
    localparam AND = 5'h05;
    localparam OR  = 5'h06;
    localparam XOR = 5'h07;
    localparam NOT = 5'h08;
    localparam SHL = 5'h09;
    localparam SHR = 5'h0A;

    // 33-bit temp to capture carry-out
    reg [32:0] temp;

    always @(*) begin
        // Safe defaults
        result = 32'b0;
        c      = 1'b0;
        v      = 1'b0;
        temp   = 33'b0;

        case (ALUOp)

            LD: begin
                result = busA;
            end

            ADD: begin
                temp   = {1'b0, busA} + {1'b0, busB};
                result = temp[31:0];
                c      = temp[32];
                // Overflow for signed addition:
                // same-sign inputs, different-sign result
                v = (~(busA[31] ^ busB[31])) & (busA[31] ^ result[31]);
            end

            SUB: begin
                temp   = {1'b0, busA} - {1'b0, busB};
                result = temp[31:0];
                c      = temp[32];
                // Overflow for signed subtraction:
                // different-sign inputs, result sign differs from busA
                v = (busA[31] ^ busB[31]) & (busA[31] ^ result[31]);
            end

            AND: begin
                result = busA & busB;
            end

            OR: begin
                result = busA | busB;
            end

            XOR: begin
                result = busA ^ busB;
            end

            NOT: begin
                result = ~busA;
            end

            SHL: begin
                result = busA << busB[4:0];
                if (busB[4:0] != 0)
                    c = busA[32 - busB[4:0]];
            end

            SHR: begin
                result = busA >> busB[4:0];
                if (busB[4:0] != 0)
                    c = busA[busB[4:0] - 1];
            end

            default: begin
                result = 32'b0;
                c      = 1'b0;
                v      = 1'b0;
            end
        endcase
    end

    assign z = (result == 32'b0);
    assign n = result[31];

endmodule
