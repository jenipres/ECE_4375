`timescale 1ns / 1ps
// R11911335
module FOUR_INPUT_MUL(A,B,C,D,sel,X);
// initialize
input [7:0] A,B,C,D;
input [1:0] sel;
output reg [7:0] X;
assign x = sel | A | B | C | D;

// assign output X to inputs into a multiplexer
always @(*) 
begin : MUX
	case(sel) 
	2'd0 : X = A;
	2'd1 : X = B;
	2'd2 : X = C;
	2'd3 : X = D;
	endcase 
end 

endmodule


