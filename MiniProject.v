module MiniProject (
    // Clock
	input clock,
	// Global Reset
	input globalReset,
	// KEY inputs
	input key0,
	input key1,
	input key2,
	input key3,
	// Application Reset for debug
	output resetApp,

	// LT24 Interface
	output LT24Wr_n,
	output LT24Rd_n,
	output LT24CS_n,
	output LT24RS,
	output LT24Reset_n,
	output [15:0] LT24Data,
	output LT24LCDOn,
	
	//7seg displays
	output [6:0] hex5,
	output [6:0] hex4,
	output [6:0] hex3,
	output [6:0] hex2
	);
	

// game parameters
parameter LCD_WIDTH  = 240;
parameter LCD_HEIGHT = 320;
//game speed, at clock = 50Mhz an object will move one pixel unit every:
//SPEED * 1/50000000 seconds  (the higher the speed the slower the object)
parameter SPEED = 400000;
parameter PADDLE_SIZE = 40;

// LCD Display
LT24Display #(
    .WIDTH       (LCD_WIDTH  ),
    .HEIGHT      (LCD_HEIGHT ),
    .CLOCK_FREQ  (50000000   )
) Display (
    //Clock and Reset In
    .clock       (clock      ),
    .globalReset (globalReset),
    //Reset for User Logic
    .resetApp    (resetApp   ),
    //Pixel Interface
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    //Use pixel addressing mode
    .pixelRawMode(1'b0       ),
    //Unused Command Interface
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    //Display Connections
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

//sync key inputs to clock, prevent metastability issues
wire key00;
wire key11;
wire key22;
wire key33;

NBitSynchroniser #(
    .WIDTH(1),
    .LENGTH(2)
) sync0(
   .asyncIn(key0),
	.clock(clock),
	
   .syncOut(key00)
);

NBitSynchroniser #(
    .WIDTH(1),
    .LENGTH(2)
) sync1(
   .asyncIn(key1),
	.clock(clock),
	
   .syncOut(key11)
);

NBitSynchroniser #(
    .WIDTH(1),
    .LENGTH(2)
) sync2(
   .asyncIn(key2),
	.clock(clock),
	
   .syncOut(key22)
);

NBitSynchroniser #(
    .WIDTH(1),
    .LENGTH(2)
) sync3(
   .asyncIn(key3),
	.clock(clock),
	
   .syncOut(key33)
);



//paddle modules
wire drawPaddle0;
wire drawPaddle1;
wire [7:0] paddleX0;
wire [7:0] paddleX1;

PaddleControl #(
	.PLAYER (0),
	.SPEED (SPEED),
	.WIDTH (LCD_WIDTH),
	.HEIGHT (LCD_HEIGHT),
	.PADDLE_SIZE (PADDLE_SIZE)
) Paddle0 (
	.clock (clock),
	.reset (~running),
	.xCount (xCount),
	.yCount (yCount),
	.paddleUp (key22),
	.paddleDown	(key33),
	
	.drawPaddle (drawPaddle0),
	.paddleX (paddleX0)
);

PaddleControl #(
	.PLAYER(1),
	.SPEED (SPEED),
	.WIDTH (LCD_WIDTH),
	.HEIGHT (LCD_HEIGHT),
	.PADDLE_SIZE (PADDLE_SIZE)
) Paddle1 (
	.clock (clock),
	.reset (~running),
	.xCount (xCount),
	.yCount (yCount),
	.paddleUp (key00),
	.paddleDown	(key11),
	
	.drawPaddle (drawPaddle1),
	.paddleX (paddleX1)
);


//ball module
wire drawBall;
wire [7:0] ballX;
wire [8:0] ballY;

BallControl #(
	.SPEED (SPEED),
	.WIDTH (LCD_WIDTH),
	.HEIGHT (LCD_HEIGHT),
	.PADDLE_SIZE (PADDLE_SIZE)
) Ball (
	.clock (clock),
	.reset (~running),
	.xCount (xCount),
	.yCount (yCount),
	.paddleX0 (paddleX0),
	.paddleX1 (paddleX1),
	
	.drawBall (drawBall),
   .ballX(ballX),
   .ballY(ballY)
);

//Pong finite state machine module
wire running;
wire [3:0] score0;
wire [3:0] score1;

PongFSM #(
	.SPEED(SPEED),
	.HEIGHT(LCD_HEIGHT)
) PongFSM (
	.clock(clock),
   .reset(resetApp),
   .start(key00),
	
	.ballX(ballX),
	.ballY(ballY),
	
	.running(running),
	.score0(score0),
	.score1(score1)
);

SevenSegManager SevenSeg (
	.clock (clock),
	.reset (resetApp),
	.running (running),
	.score0 (score0),
	.score1 (score1),
	
	.hex2 (hex2),
	.hex3 (hex3),
	.hex4 (hex4),
	.hex5 (hex5)
);

// X Counter
wire [7:0] xCount;

UpCounterNbit #(
    .WIDTH    (          8),
    .MAX_VALUE(LCD_WIDTH-1)
) xCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (pixelReady),
    .countValue(xCount    )
);

// Y Counter
wire [8:0] yCount;
wire yCntEnable = pixelReady && (xCount == (LCD_WIDTH-1));

UpCounterNbit #(
    .WIDTH    (           9),
    .MAX_VALUE(LCD_HEIGHT-1)
) yCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (yCntEnable),
    .countValue(yCount    )
);

// drawing shapes, local variables
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;

// Pixel Write
always @ (posedge clock or posedge resetApp) begin

    if (resetApp) begin
	 
        pixelWrite <= 1'b0;
		  
    end else begin
	 
        //always set write high, and use pixelReady to detect when
        //to update the data.
        pixelWrite <= 1'b1;
    
    end
end

//draw the shapes
always @ (posedge clock or posedge resetApp) begin

	if (resetApp) begin
	
		pixelData <= 16'b0;
		xAddr <= 8'b0;
		yAddr <= 9'b0;
		
	end else if (pixelReady) begin
		
		if(drawPaddle0) begin
		
			xAddr <= xCount;
			yAddr <= yCount;
			pixelData[15:0] <= 16'h001F;
			
		end else if(drawPaddle1) begin
		
			xAddr <= xCount;
			yAddr <= yCount;
			pixelData[15:0] <= 16'hF800;
			
		end else if(drawBall) begin
		
			xAddr <= xCount;
			yAddr <= yCount;
			pixelData[15:0] <= 16'b0;
			
		end else begin
		
			xAddr <= xCount;
			yAddr <= yCount;
			pixelData[15:0] <= {(16){1'b1}};
			
		end
	end
end


endmodule 