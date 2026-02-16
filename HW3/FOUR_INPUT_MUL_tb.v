`timescale 1ns / 1ps
module FOUR_INPUT_MUX_tb;
// JENICO PRESTON R11911335
	// Inputs
	reg [7:0] A;
	reg [7:0] B;
	reg [7:0] C;
	reg [7:0] D;
	reg [2:0] sel;

	// Outputs
	wire [7:0] X;

	// Instantiate the Unit Under Test (UUT)
	FOUR_INPUT_MUL uut (
		.A(A), 
		.B(B), 
		.C(C), 
		.D(D), 
		.sel(sel), 
		.X(X)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		C = 0;
		D = 0;
		sel = 0;

		// Wait 20 ns for global reset to finish
		#20;
		A = 3; B = 9; C = 27; D = 81; sel = 0; //output X should be 3 if sel = 0, etc...
		#20;
		A = 3; B = 9; C = 27; D = 81; sel = 1;
		#20;
		A = 3; B = 9; C = 27; D = 81; sel = 2;
		#20;
		A = 3; B = 9; C = 27; D = 81; sel = 3;
		#20;
		$finish;
       
	end
      
endmodule
