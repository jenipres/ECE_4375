`timescale 1ns / 1ps
module CoinCounter(inquarter, indime, innickel, outCount, resetCount);
parameter QUARTER_VALUE = 25;
parameter DIME_VALUE = 10;
parameter NICKEL_VALUE = 5;

input inquarter, indime, innickel, resetCount;
output reg [9:0] outCount;
wire inMoney;
reg [9:0] moneyCounter;

assign inMoney = inquarter | indime | innickel | resetCount;

always @(inMoney) begin
	if(resetCount == 1) begin 
		moneyCounter <= 0;
	end else begin 
		moneyCounter <= moneyCounter + (inquarter*QUARTER_VALUE + indime * DIME_VALUE + innickel * NICKEL_VALUE);
		end
	end
	
endmodule
