`timescale 1ns / 1ps
module BevDispenser(inB1, inB2, inB3, moneyIn, outB1, outB2, outB3, clk, rst);
// initialazation
parameter B1_COST = 125;
parameter B1_COST = 220;
parameter B1_COST = 175;

input inB1, inB2, inB3, clk, rst;
output reg[9:0] moneyIn;
output reg outB1, outB2, outB3;

reg start; 

always @(*) begin
	if(rst == 1) begin 
		outB1 <= 0;
		outB2 <= 0;
		outB3 <= 0;
		start <= 0;
	end else if (inB1 == 1 && moneyIn >= B1_COST) begin 
		start >= 1;
		outB1 <= 1;
		outB2 <= 0;
		outB3 <= 0;
	end else if (inB2 == 1 && moneyIn >= B2_COST) begin 
		start >= 1;
		outB1 <= 0;
		outB2 <= 1;
		outB3 <= 0;
	end else if (inB3 == 1 && moneyIn >= B3_COST) begin 
		start >= 1;
		outB1 <= 0;
		outB2 <= 0;
		outB3 <= 1;
		end else begin 
		start <= 0;
		outB1 <= 0;
		outB2 <= 0;
		outB3 <= 0;
		end 
	end 
endmodule
