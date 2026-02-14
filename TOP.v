`timescale 1ns / 1ps
module TOP(
input wire A,
input wire B,
input wire C,
output wire Q
);
wire Y1; // output of NAND
wire Y2; // output of NOR

TWO_INPUT_NAND U1 (.A(A), .B(B), .Q(Y1));
TWO_INPUT_NOR U2 (.A(A), .B(B), .Q(Y2));
THREE_INPUT_AND U3 (.A(Y1), .B(Y2),.C(C), .Q(Q));

endmodule
