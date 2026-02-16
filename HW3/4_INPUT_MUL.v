`timescale 1ns / 1ps
// R11911335
module FOUR_INPUT_MUL(A,B,C,D,sel,X);
// initialize
input [7:0] A,B,C,D,sel;
output [7:0] X;
reg X;
assign x = sel | A | B | C | D;

// assign output X to inputs into a multiplexer
always @(x) begin 
if(sel = 1'b0) begin
	X = A;
end else begin

if(sel = 2'b0) begin 
	X = B;
end else begin 

if(sel = 3'b0) begin
	X = C;
end else begin 
	
if(sel = 4'b0) begin 
	X = D;
	end
end 

endmodule

