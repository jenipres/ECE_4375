`timescale 1ns / 1ps
module TwoToFourDecoder(A,W,X,Y,Z);
input [1:0] A;
output reg W,X,Y,Z;

always @(A)begin
	case(A)
	2'b00: begin
		W<=1;
		X<=0;
		Y<=0;
		Z<=0;
	end
	2'b01:begin 
		W<=0;
		X<=1;
		Y<=0;
		Z<=0;
	end
	2'b10: begin
		W<=0;
		X<=0;
		Y<=1;
		Z<=0;
	end
	2'b11:begin 
		W<=0;
		X<=0;
		Y<=0;
		Z<=1;
	end 
	endcase
end

endmodule
