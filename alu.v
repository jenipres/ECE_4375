/*
Name: Jenico Preston
R-Number: R11911335
Assignment: Project 3
*/
module alu (
    input wire clk,
    input wire reset,
    input wire [31:0] busA,
    input wire [31:0] busB,
    input wire [4:0]  ALUOp,

    output reg  [31:0] result,
    output wire        z,
    output wire        n,
    output reg         c,
    output reg         v
);

    // Operation encoding (control unit will drive ALUOp)
    localparam ADD = 5'b00000;
    localparam SUB = 5'b00001;
    localparam NOT = 5'b00010;
    localparam AND = 5'b00011;
    localparam OR  = 5'b00100;
    localparam XOR = 5'b00101;
    localparam SHR = 5'b00110;
    localparam SHL = 5'b00111;
    localparam LD  = 5'b01000;
    
    // 33-bit temp register to capture carry-out (bit 32)
    reg [32:0] temp;

    always @(*) begin
        // Default values to avoid unintended latches
        result = 32'b0;
        c = 1'b0;
        v = 1'b0;
        temp = 33'b0;

        case (ALUOp)
            ADD: begin
              temp = {1'b0, busA} + {1'b0, busB}; // Extend to 33 bits so we can capture carry-out
              result = temp [31:0];
              c = temp[32:0]; // carry-out
              v = (~(busA[31] ^ busB[31])) & (busA[31] ^ result[31]); // Overflow: same sign inputs, different sign result
            end

            SUB: begin
              temp = {1'b0, busA} - {1'b0, busB};
                result = temp [31:0];
                c = temp[32:0]; // carry-out
                v = (~(busA[31] ^ busB[31])) & (busA[31] ^ result[31]);
            end

            NOT: begin
               result = ~busA;
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

            SHR: begin
                result = busA >> busB[4:0]; // shift amount = lower 5 bits
                if (busB[4:0] != 0)
                c = busA[busB[4:0]-1]; // last bit shifted out
            end

            SHL: begin
                result = busA << busB[4:0];
                if (busB[4:0] != 0)
                c = busA[32 - busB[4:0]]; // last bit shifted out
            end

            LD: begin
                result = busA; // move operation
            end

            default: begin
               
            end
        endcase
    end

    assign z = (result == 32'b0);
    assign n = result[31];

endmodule
assign zero = (result == 8'h00);

endmodule
