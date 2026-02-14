`timescale 1ns / 1ps
module TOP_TB;

	// Inputs
	reg A;
	reg B;
	reg C;

	// Outputs
	wire Q;

	// Instantiate the Unit Under Test (UUT)
	TOP uut (
		.A(A), 
		.B(B), 
		.C(C), 
		.Q(Q)
	);
integer index;
	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		C = 0;

		// Wait 20 ns for global reset to finish
		#20;
		$display("A B C | Q");
		for(index = 0; index < 8; index = index + 1) begin 
			{A, B, C} = index;
			#20;
			$display("%b %b %b | %b", A, B, C, Q);
		end 
		$finish;
		
	end
      
endmodule
