//Hex to 7 segnment display conversion

module SevenSegment #(
	parameter INVERT_OUTPUT = 0
)(

	input [3:0] hexValue,
	output [6:0] sevenSeg
	
);

	reg [6:0] segValue;

	always @ * begin 

		case (hexValue)
			
			4'h0: segValue = 7'b0111111;
			4'h1: segValue = 7'b0000110;
			4'h2: segValue = 7'b1011011;
			4'h3: segValue = 7'b1001111;
			4'h4: segValue = 7'b1100110;
			4'h5: segValue = 7'b1101101;
			4'h6: segValue = 7'b1111101;
			4'h7: segValue = 7'b0000111;
			4'h8: segValue = 7'b1111111;
			4'h9: segValue = 7'b1100111;
			4'hA: segValue = 7'b1110011;	//P
			4'hB: segValue = 7'b1011100;	//o
			4'hC: segValue = 7'b1010100;	//n
			4'hD: segValue = 7'b0111101;	//g
			4'hE: segValue = 7'b0; //turn off display
			
			
			default segValue = 7'b0000000; //default value
			
		endcase 
		
	end
	
	assign sevenSeg = INVERT_OUTPUT ? ~segValue : segValue;
	
endmodule
