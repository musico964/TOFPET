/********************************************************************
* Module:    switch_debouncer
* Author:    David T. Johnson
* Function:  Metastabilizes and debounces a push button
* Revision:  1.0  July 21, 2005
********************************************************************/

//Copyright © 2005 Altera Corporation. All rights reserved.  Altera products 
//are protected under numerous U.S. and foreign patents, maskwork rights, 
//copyrights and other intellectual property laws.  
//
//This reference design file, and your use thereof, is subject to and governed
//by the terms and conditions of the applicable Altera Reference Design 
//License Agreement.  By using this reference design file, you indicate your
//acceptance of such terms and conditions between you and Altera Corporation.
//In the event that you do not agree with such terms and conditions, you may
//not use the reference design file. Please promptly destroy any copies you 
//have made.
//
//This reference design file being provided on an "as-is" basis and as an 
//accommodation and therefore all warranties, representations or guarantees
//of any kind (whether express, implied or statutory) including, without 
//limitation, warranties of merchantability, non-infringement, or fitness for
//a particular purpose, are specifically disclaimed.  By making this reference
//design file available, Altera expressly does not recommend, suggest or 
//require that this reference design file be used in combination with any 
//other product not provided by Altera

//                       Open             Bouncing    Closed
// Signal from switch  11111111111111111???????????000000000000
// After synchonizer   1111111111111111100100101100000000000000
// Sampled (s)		     s--------s--------s--------s--------s
// Output                1111111111111111110000000000000000000

module switch_debouncer
(
	clk,
	reset_n,
	data_in,
	data_out			
);
						
	parameter			preset_val 	= 0;
	parameter 			counter_max = 100000;
												// Determines sample rate of push button
												// Set to > # of clocks that switch bounce occurs
	parameter			ctr_width	=	21;		// Set to ceil(log2(counter_max))									
	input				clk;
	input				reset_n;
	input				data_in;
	output				data_out;
										
	reg					data_out;									
// Internal data structures:
	reg					data_in_0;	// 4 deep metastabilier
	reg					data_in_1;
	reg					data_in_2;
	reg					data_in_3;
	reg	[ctr_width-1:0]	counter;
	

	always	@(posedge clk or negedge reset_n)
	begin
		if	(!reset_n)
		begin
			data_out		<=	preset_val;
			counter			<=	counter_max;
			data_in_0		<=	0;
			data_in_1		<=	0;
			data_in_2		<=	0;
			data_in_3		<=	0;			
		end else begin
			if	(counter == 0) // Sample metastabilized push button
			begin
				data_out	<=	data_in_3;
				counter		<=	counter_max;
			end else begin
				counter		<=	counter - 1;
			end
			data_in_0	<=	data_in;	// Metastablizer / Synchronizer
			data_in_1	<=	data_in_0;
			data_in_2	<=	data_in_1;
			data_in_3	<=	data_in_2;
		end
	end
				
					

endmodule
