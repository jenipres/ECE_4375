`timescale 1ns / 1ps
module CoinCounter_tb;

	// Inputs
	reg inquarter;
	reg indime;
	reg innickel;
	reg resetCount;

	// Outputs
	wire [9:0] outCount;

	// Instantiate the Unit Under Test (UUT)
	CoinCounter uut (
		.inquarter(inquarter), 
		.indime(indime), 
		.innickel(innickel), 
		.outCount(outCount), 
		.resetCount(resetCount)
	);

	initial begin
		// Initialize Inputs
		inquarter = 0;
		indime = 0;
		innickel = 0;
		resetCount = 0;

		// Wait 20 ns for global reset to finish
		#20;
        
		resetCount = 1;
		#20;
		resetCount = 0;
		#20;
		
		inquarter = 1;
		#20;
		inquarter = 0;
		#20;
		
		$finish;

	end
      
endmodule
