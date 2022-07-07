module BallControl #(
	parameter SPEED = 500000,
	parameter WIDTH = 240,
	parameter HEIGHT = 320,
	parameter PADDLE_SIZE = 40
)(
	input clock,
	input reset,
	input [7:0] xCount,
	input [8:0] yCount,
	input [7:0] paddleX0,
	input [7:0] paddleX1,
	
	output reg drawBall,
   output reg [7:0] ballX = 0,
   output reg [8:0] ballY = 0
);

//ball size
localparam SIZE = 2;

//increase the ball velocity for a mole challenging gameplay
localparam MOD_SPEED = SPEED - 150000;

//store previous position values to decide direction
//if previous value lower than current then ball moving forward and vice versa
//applies to both width and height movement
reg [7:0]  ballXP; 
reg [8:0]  ballYP;  
  
reg [31:0] ballCount = 0;

always @(posedge clock) begin

	//define starting position
	if (reset) begin
	
		ballX <= WIDTH/2;
		ballY <= HEIGHT/2;
		ballXP <= WIDTH/2 - 1;
		ballYP <= HEIGHT/2 - 1;
		
	end else begin

		if (ballCount < MOD_SPEED) begin
		
			ballCount <= ballCount + 1;
			
		end else begin
		
			ballCount <= 0;
			ballXP <= ballX;
			ballYP <= ballY;
			
			//First check if colliding with paddles, then if colliding with wall, then consdier direction
			if (ballY == 5 && ballX >= paddleX0 && ballX <= paddleX0 + PADDLE_SIZE) begin
			
				ballY <= ballY + 8'b1;
				
			end else if (ballY == HEIGHT - 6 && ballX >= paddleX1 && ballX <= paddleX1 + PADDLE_SIZE) begin
			
				ballY <= ballY - 8'b1;
				
			end else if (ballY == 1) begin
			
				ballY <= ballY + 8'b1;
				
			end else if (ballY == HEIGHT - 1) begin
			
				ballY <= ballY - 8'b1;
				
			end else if (ballYP < ballY) begin
			
				ballY <= ballY + 8'b1;
				
			end else if (ballYP > ballY) begin
			
				ballY <= ballY - 8'b1;
				
			end
			
			//for X, only check if at wall, then consider direction
			if (ballX == 1) begin
			
				ballX <= ballX + 8'b1;
				
			end else if (ballX == WIDTH - 1) begin
			
				ballX <= ballX - 8'b1;
				
			end else if (ballXP < ballX) begin
			
				ballX <= ballX + 8'b1;
				
			end else if (ballXP > ballX) begin
			
				ballX <= ballX - 8'b1;
				
			end
		end	
	end
end 

always @(posedge clock) begin

	if(reset)begin
	
		drawBall <= 1'b0;
		
	end else begin

		if (yCount >= ballY - SIZE && yCount <= ballY + SIZE  && xCount >= ballX - SIZE && xCount <= ballX + SIZE) begin
		
			drawBall <= 1'b1;
			
		end else begin
		
			drawBall <= 1'b0;
			
		end
	end
end 


endmodule 