`timescale 1 ns/100 ps
 
module BallControl_tb;
//
// Parameter Declarations
//
localparam NUM_CYCLES = 2000000;       //Simulate this many clock cycles. Max. 1 billion
localparam CLOCK_FREQ = 50000000; //Clock frequency (in Hz)
localparam RST_CYCLES = 5;        //Number of cycles of reset at beginning.
//
// Test Bench Generated Signals
//
reg  clock;
reg  reset;
reg [7:0] xCount;
reg [8:0] yCount;

wire drawBall;
wire [7:0] ballX;
wire [8:0] ballY;
//
// Device Under Test
//

BallControl BallControl_dut (
	.clock (clock),
	.reset (reset),
	.xCount (xCount),
	.yCount (yCount),
	
	.drawBall (drawBall),
	.ballX (ballX),
	.ballY (ballY)
);

//
// Test Bench Logic
//

initial begin

	//Print to console that the simulation has started. $time is the current sim time.
	$display("%d ns\tSimulation Started",$time);
	//Monitor changes to any values listed, and automatically print to the console 
   //when they change. There can only be one $monitor per simulation.
   $monitor("%d ns\treset=%d\txCount=%d\tyCount=%d\tdrawBall=%b\tballX=%d\tballY=%d",$time,reset,xCount,yCount,drawBall,ballX,ballY);
	
	xCount = 8'b0;
	yCount = 9'b0;
	
	
	reset = 1'b1;                        //Start in reset.
   repeat(RST_CYCLES) @(posedge clock); //Wait for a couple of clocks
   reset = 1'b0;                        //Then clear the reset signal.
	
	
	$display("Checking initial position...");
	
	repeat(5) @(posedge clock);
	
	//check initial position
	if (ballX == 8'd120 && ballY == 9'd160) begin
		$display("Initial position Success!");
	end else begin
		$display("ERROR! Initial position(X,Y) = (%d,%d) != (120,160)",ballX,ballY);
	end
	//////////
	
	
	$display("Checking movement ...");
	
	repeat(500005) @(posedge clock);
	
	//check if ball moves up and away from paddle
	if (ballX >= 8'd120) begin
		$display("Moving the ball up Success!");
	end else begin
		$display("ERROR moving up! position(X,Y) = (%d,%d) != (>120,>160)",ballX,ballY);
	end
	//////////
	
	
	$display("Checking ball drawing...");
	
	reset = 1'b1;                        
   repeat(RST_CYCLES) @(posedge clock); 
   reset = 1'b0;   
	
	repeat(5) @(posedge clock);
	
	yCount = 9'd160;
	xCount = 8'd120;
	
	repeat(5) @(posedge clock);
	
	//check if ball draws
	if (drawBall == 1'b1) begin
		$display("Drawing the ball Success!");
	end else begin
		$display("ERROR! drawBall = %b != 1",drawBall);
	end
	//////////
	
end

//
// Reset Logic
//
//Clock generator + simulation time limit.
//
initial begin
    clock = 1'b0; //Initialise the clock to zero.
end
//Next we convert our clock period to nanoseconds and half it
//to work out how long we must delay for each half clock cycle
//Note how we convert the integer CLOCK_FREQ parameter it a real
real HALF_CLOCK_PERIOD = (1e9 / $itor(CLOCK_FREQ)) / 2.0;

//Now generate the clock
integer half_cycles = 0;
always begin
    //Generate the next half cycle of clock
    #(HALF_CLOCK_PERIOD);          //Delay for half a clock period.
    clock = ~clock;                //Toggle the clock
    half_cycles = half_cycles + 1; //Increment the counter
    //Check if we have simulated enough half clock cycles
    if (half_cycles == (2*NUM_CYCLES)) begin 
        //Once the number of cycles has been reached
		half_cycles = 0; 		   //Reset half cycles
		$display("%d ns\tSimulation Finished",$time); //Finished
        $stop;                     //Break the simulation
        //Note: We can continue the simualation after this breakpoint using 
        //"run -all", "run -continue" or "run ### ns" in modelsim.
    end
end

endmodule