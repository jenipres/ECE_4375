`timescale 1ns / 1ps
module THREE_INPUT_AND(
    input A,
    input B,
    input C,
    output Q
);
assign Q = (A & B & C);

endmodule
