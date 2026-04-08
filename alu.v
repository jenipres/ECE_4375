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

    // ALU operation codes
    localparam ADD = 5'b00000;
    localparam SUB = 5'b00001;
    localparam NOT = 5'b00010;
    localparam AND = 5'b00011;
    localparam OR  = 5'b00100;
    localparam XOR = 5'b00101;
    localparam SHR = 5'b00110;
    localparam SHL = 5'b00111;
    localparam LD  = 5'b01000;

    reg [32:0] temp;

    always @(*) begin
        // defaults
        result = 32'b0;
        c = 1'b0;
        v = 1'b0;
        temp = 33'b0;

        case (ALUOp)
            ADD: begin
              temp = {1'b0, busA} + {1'b0, busB};
              
            end

            SUB: begin
              temp = {1'b0, busA} - {1'b0, busB};
            end

            NOT: begin
               
            end

            AND: begin
              
            end

            OR: begin
               
            end

            XOR: begin
                
            end

            SHR: begin
               
            end

            SHL: begin
                
            end

            LD: begin
                
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
