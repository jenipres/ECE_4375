`timescale 1ns / 1ps
module CoinCounter_tb;

	// Inputs
	reg inQ;
	reg inD;
	reg inN;
	reg resetCount;

	// Outputs
	wire [9:0] outCount;

	// Instantiate the Unit Under Test (UUT)
	CoinCounter uut (
		.inQ(inQ), 
		.inD(inD), 
		.inN(inN), 
		.outCount(outCount), 
		.resetCount(resetCount)
	);

	initial begin
		// Initialize Inputs
		inQ = 0;
		inD = 0;
		inN = 0;
		resetCount = 0;

		// Wait 20 ns for global reset to finish
		#20;
        
		resetCount = 1;
		#20;
		resetCount = 0;
		#20;
		//quarter test
		inQ = 1;
		#20;
		inQ = 0;
		#20;
		// dime test
		inD = 1;
		#20;
		inD = 0;
		#20;
		// nickel test 
		inN = 1;
		#20;
		inN = 0;
		#20;
		$finish;
	end
      
endmodule
