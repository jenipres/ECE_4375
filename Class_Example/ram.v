`timescale 1ns / 1ps
module Ram(dataIN, dataOut, WR, RD, addr);
input [3:0] dataIN;
input WR, RD;
input [3:0] addr;

output reg[3:0] dataOut;

reg[3:0] dataSTORE[15:0];

always@(posedge WR) begin
dataSTORE[addr]<= dataIN;
end 

always@(posedge RD) begin
dataOut <= dataSTORE[addr];
end 


endmodule
