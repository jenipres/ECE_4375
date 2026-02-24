`timescale 1ns / 1ps
module CoinCounter(inQ, inD, inN, outCount, resetCount);
//initialazaion 
parameter Q_VALUE = 25;
parameter D_VALUE = 10;
parameter N_VALUE = 5;

input inQ, inD, inN, resetCount;
output reg[9:0] outCount;
wire inMoney;
reg[9:0] moneyCounter;

assign inMoney = inQ |inD | inN |resetCount;

always @(inMoney)begin 
	if(resetCount == 1) begin
		outCount <= 0;
	end else begin
		outCount <= outCount + (inQ * Q_VALUE + inD * D_VALUE + inN * N_VALUE);
	end 
end 

endmodule 
