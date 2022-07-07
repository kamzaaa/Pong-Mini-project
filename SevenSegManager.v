module SevenSegManager (
	input clock,
	input reset,
	input running,
	input [3:0] score0,
	input [3:0] score1,
	
	output [6:0] hex2,
	output [6:0] hex3,
	output [6:0] hex4,
	output [6:0] hex5
);

parameter MAXSCORE = 9;

reg [3:0] seg2wire;
reg [3:0] seg3wire;
reg [3:0] seg4wire;
reg [3:0] seg5wire;

SevenSegment #(
	.INVERT_OUTPUT(1)
) seg2 (

	.hexValue(seg2wire),
	
	.sevenSeg(hex2)
	
);

SevenSegment #(
	.INVERT_OUTPUT(1)
) seg3 (

	.hexValue(seg3wire),
	
	.sevenSeg(hex3)
	
);

SevenSegment #(
	.INVERT_OUTPUT(1)
) seg4 (

	.hexValue(seg4wire),
	
	.sevenSeg(hex4)
	
);

SevenSegment #(
	.INVERT_OUTPUT(1)
) seg5 (

	.hexValue(seg5wire),
	
	.sevenSeg(hex5)
	
);

//while game running display score and then announce the winner
//while no game running simply display "pong"
always @ (posedge clock) begin 

	if (reset) begin
	
		seg2wire <= 4'b0;
		seg3wire <= 4'b0;
		seg4wire <= 4'b0;
		seg5wire <= 4'b0;
		
	end else if (running == 1) begin
		
		seg5wire <= score0;
		seg4wire <= 4'hE; 
		seg3wire <= 4'hE; 
		seg2wire <= score1;
		
	end else begin
	
		if (score0 == MAXSCORE || score1 == MAXSCORE) begin
		
			if (score0 > score1) begin
				
				seg5wire <= 4'hA; //p
				seg4wire <= 4'h1; //1
				seg3wire <= 4'hE; 
				seg2wire <= 4'hE;
				
			end else begin
				
				seg5wire <= 4'hE; 
				seg4wire <= 4'hE;
				seg3wire <= 4'hA; //p
				seg2wire <= 4'h2; //2
				
			end
		
		end else begin
		
			seg5wire <= 4'hA;	//p
			seg4wire <= 4'hB; //o
			seg3wire <= 4'hC; //n
			seg2wire <= 4'hD; //g
			
		end
	end	
end

endmodule 