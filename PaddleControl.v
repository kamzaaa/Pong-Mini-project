module PaddleControl #(
	parameter PLAYER = 0,
	parameter SPEED = 500000,
	parameter WIDTH = 240,
	parameter HEIGHT = 320,
	parameter PADDLE_SIZE = 40
)(
	input clock,
	input reset,
	input [7:0] xCount,
	input [8:0] yCount,
	input paddleUp,
	input paddleDown,
	
	output reg drawPaddle,
	output reg [7:0] paddleX
);

reg [31:0] paddleCount = 0;
wire NotPaddleUp = ~paddleUp;
wire NotPaddleDown = ~paddleDown;

always @(posedge clock) begin
	
	//define starting position
	if (reset) begin
	
		paddleX <= WIDTH/2 - PADDLE_SIZE/2;
		
	end else begin 

		if (paddleCount == SPEED) begin
		
			paddleCount <= 0;
			
		end else begin
		
		  paddleCount <= paddleCount + 1;
		  
		end
		
		//Update paddle location when paddle count at limit and not edge of screen of screen
		if (NotPaddleDown == 1'b1 && paddleCount == SPEED && paddleX != 0) begin
		
			paddleX <= paddleX - 1'b1;
			
		end else if (NotPaddleUp == 1'b1 && paddleCount == SPEED && paddleX != WIDTH - PADDLE_SIZE) begin
		
			paddleX <= paddleX + 1'b1;
			
		end	
	end
end

//Draws the Paddles based on determined paddle location
always @(posedge clock) begin

	if(reset)begin
	
		drawPaddle <= 1'b0;
		
	end else begin

		if (PLAYER == 0) begin
		
			if (yCount <= 5 && xCount >= paddleX && xCount <= paddleX + PADDLE_SIZE) begin
			
				drawPaddle <= 1'b1;
				
			end else begin
			
				drawPaddle <= 1'b0;
				
			end
			
		end else begin
		
			if (yCount >= HEIGHT - 6 && xCount >= paddleX && xCount <= paddleX + PADDLE_SIZE) begin
			
				drawPaddle <= 1'b1;
				
			end else begin
			
				drawPaddle <= 1'b0;
				
			end
		end
	end
end 


endmodule 