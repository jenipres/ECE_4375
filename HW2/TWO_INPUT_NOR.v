`timescale 1ns / 1ps
module TWO_INPUT_NOR(
    input A,
    input B,
    output Q
);

assign Q = ~(A | B);


endmodule
