`timescale 1ns / 1ps
module TwoToFourDecoder_tb;

	// Inputs
	reg [1:0] A;

	// Outputs
	wire W;
	wire X;
	wire Y;
	wire Z;

	// Instantiate the Unit Under Test (UUT)
	TwoToFourDecoder uut (
		.A(A), 
		.W(W), 
		.X(X), 
		.Y(Y), 
		.Z(Z)
	);

	initial begin
		// Initialize Inputs
		A = 0;

		// Wait  ns for global reset to finish
		#20;
        integer index;
		  for(index = 0; index < 4; index = index +1)begin
			A = index[1:0];
			#20;
		  end
		$finish;
	end
      
endmodule
