module PongFSM #(
	parameter SPEED = 500000,
	parameter HEIGHT = 320
)(
	input clock,
   input reset,
   input start,
	
	input [7:0]	ballX,
	input [8:0] ballY,
	
	output reg running,
	output reg [3:0] score0,
	output reg [3:0] score1
);

//invert input
wire nstart = ~start;

//game parameter
localparam MAXSCORE = 9;
localparam MOD_SPEED = SPEED - 150000;
localparam SEC = 50000000;

//FSM registers
reg [1:0] state;
reg [31:0] ballCount;
reg [31:0] secCount;

//states
localparam WAITING = 2'b00;
localparam RUNNING = 2'b01;
localparam GAMEOVER = 2'b10;

//the state machine, the displayed messages handled by separate 7seg manager
always @ (posedge clock or posedge reset) begin

	if (reset) begin
	
		score0 <= 4'b0;
		score1 <= 4'b0;
		running <= 1'b0;
		ballCount <= 32'b0;
		secCount <= 32'b0;
		state <= WAITING;
		
	end else begin
	
		case (state)
		
		//wait for button press, display "pong"
		WAITING: begin
			
			score0 <= 4'b0;
			score1 <= 4'b0;
			running <= 1'b0;
			
			//wait a sec first so key press from game over screen does not get picked up.
			if (secCount < SEC) begin
			
				secCount <= secCount + 1'b1;
				
			end else begin
			
				if (nstart == 1'b1) begin
				
					secCount <= 32'b0;
					state <= RUNNING;
					
				end else begin
				
					state <= WAITING;
					
				end
			end
		end
		
		//give points when ball lands at edge of screen, end game when points limit reached
		RUNNING: begin
		
			running <= 1'b1;

			//wait MOD_SPEED amount of clock cycles before awarding a point so the ball moves on to the next pixel
			if (ballY == 1) begin
			
				if (ballCount < MOD_SPEED) begin
				
					ballCount <= ballCount + 1;
					
				end else begin
				
					ballCount <= 0;
					score1 <= score1 + 4'b1;
					
				end
					
			end 
			
			if (ballY == HEIGHT - 1) begin
			
				if (ballCount < MOD_SPEED) begin
				
					ballCount <= ballCount + 1;
					
				end else begin
				
					ballCount <= 0;
					score0<= score0 + 4'b1;
					
				end
				
			end
			
			if (score0 == MAXSCORE) begin
			
				state <= GAMEOVER;
				
			end else if (score1 == MAXSCORE) begin
			
				state <= GAMEOVER;
				
			end else begin
				
				state <= RUNNING;
				
			end
			
		end
		
		//display "p1" or "p2" based on who won and go back to WAITING when button press
		GAMEOVER: begin
		
			running <= 1'b0;
			
			//wait a sec first so key press from the finished game does not get picked up.
			if (secCount < SEC) begin
			
				secCount <= secCount + 1'b1;
				
			end else begin
			
				if (nstart == 1'b1) begin
				
					secCount <= 32'b0;
					state <= WAITING;
					
				end else begin
				
					state <= GAMEOVER;
					
				end
			end
		end
		
		endcase
	end
end	


endmodule 