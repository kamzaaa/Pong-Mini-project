`timescale 1 ns/100 ps
 
module SevenSegManager_tb;
//
// Parameter Declarations
//
localparam NUM_CYCLES = 50;       //Simulate this many clock cycles. Max. 1 billion
localparam CLOCK_FREQ = 50000000; //Clock frequency (in Hz)
localparam RST_CYCLES = 5;        //Number of cycles of reset at beginning.
//
// Test Bench Generated Signals
//
reg  clock;
reg  reset;
reg running;
reg [3:0] score0;
reg [3:0] score1;
	
wire [6:0] hex2;
wire [6:0] hex3;
wire [6:0] hex4;
wire [6:0] hex5;
//
// Device Under Test
//

SevenSegManager SevenSegManager_dut (
	.clock (clock),
	.reset (reset),
	.running (running),
	.score0 (score0),
	.score1 (score1),
	
	.hex2 (hex2),
	.hex3 (hex3),
	.hex4 (hex4),
	.hex5 (hex5)
);

//
// Test Bench Logic
//

initial begin

	//Print to console that the simulation has started. $time is the current sim time.
	$display("%d ns\tSimulation Started",$time);
	//Monitor changes to any values listed, and automatically print to the console 
   //when they change. There can only be one $monitor per simulation.
   $monitor("%d ns\tclock=%b\treset=%b\trunning=%b\tscore0=%d\tscore1=%d\thex2=%h\thex3=%h\thex4=%h\thex5=%h",$time,clock,reset,running,score0,score1,hex2,hex3,hex4,hex5);
	
	$display("Game not running check:");
	
	running = 1'b0;
	score0 = 4'b0;
	score1 = 4'b0;
	
	reset = 1'b1;                        //Start in reset.
   repeat(RST_CYCLES) @(posedge clock); //Wait for a couple of clocks
   reset = 1'b0;                        //Then clear the reset signal.
	
	repeat(10) @(posedge clock);
	
	if (hex5 == 7'b0001100 && hex4 == 7'b0100011 && hex3 == 7'b0101011 && hex2 == 7'b1000010) begin
		$display("'pong' display success!");
	end else begin
		$display("ERROR! While game not running the displays are:");
		$display("hex5 = %b != 0001100(P)",hex5);
		$display("hex4 = %b != 0100011(o)",hex4);
		$display("hex3 = %b != 0101011(n)",hex3);
		$display("hex2 = %b != 1000010(g)",hex2);
	end
	//////////
	
	
	$display("Game running check:");
	
	running = 1'b1;
	
	repeat(5) @(posedge clock);
	
	if (hex5 == 7'b1000000 && hex2 == 7'b1000000) begin
		$display("score display zero success!");
	end else begin
		$display("ERROR! While scores are zero, the displays are:");
		$display("hex5 = %b != 1000000(0)",hex5);
		$display("hex2 = %b != 1000000(0)",hex2);
	end
	//////////
	
	
	score0 = 4'd3;
	score1 = 4'd7;
	
	repeat(5) @(posedge clock);
	
	if (hex5 == 7'b0110000 && hex2 == 7'b1111000) begin
		$display("score display success!");
	end else begin
		$display("ERROR! While score0 3 and score1 7, the displays are:");
		$display("hex5 = %b != 0110000(3)",hex5);
		$display("hex2 = %b != 1111000(7)",hex2);
	end
	//////////
	
	
	$display("Game over check:");
	
	score0 = 4'd9;
	score1 = 4'd7;
	running = 1'b0;
	
	repeat(5) @(posedge clock);
	
	if (hex5 == 7'b0001100 && hex4 == 7'b1111001) begin
		$display("Winner display success!");
	end else begin
		$display("ERROR! After player 1 wins, the displays are:");
		$display("hex5 = %b != 0001100(P)",hex5);
		$display("hex4 = %b != 1111001(1)",hex4);
	end
	
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