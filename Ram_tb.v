`timescale 1ns / 1ps

module ram_TB;

	// Inputs
	reg [3:0] dataIN;
	reg WR;
	reg RD;
	reg [3:0] addr;

	// Outputs
	wire [3:0] dataOut;

	// Instantiate the Unit Under Test (UUT)
	Ram uut (
		.dataIN(dataIN), 
		.dataOut(dataOut), 
		.WR(WR), 
		.RD(RD), 
		.addr(addr)
	);

	initial begin
		// Initialize Inputs
		dataIN = 0;
		WR = 0;
		RD = 0;
		addr = 0;

		// Wait 20 ns for global reset to finish
		#20;
		
		dataIN = 3'h5;
		#5;
		WR= 1;
		#20;
		WR = 0;
		#20;
		addr = 0;
		RD = 1;
		#20;
		RD = 0;
		#20;
		addr = 1;
		#20;
		$finish;

	end
      
endmodule

