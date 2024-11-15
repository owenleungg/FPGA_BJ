`timescale 1ns / 1ps

module testbench ( );

parameter CLOCK_PERIOD = 10;

  reg CLOCK_50;
  reg [2:0] KEY;  
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

initial begin
  CLOCK_50 <= 1'b0;
end // initial
always @ (*)
begin : Clock_Generator
	#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
end

initial begin
  KEY[0] <= 1'b1;
  KEY[1] <= 1'b1;
  end // initial
    always @ (*)
  begin : Clock_Gen
    #((CLOCK_PERIOD) / 2) KEY[0] <= ~KEY[0];
    #((CLOCK_PERIOD) / 2) KEY[0] <= ~KEY[0];
    #((CLOCK_PERIOD) / 2) KEY[1] <= ~KEY[1];
end

initial begin
  KEY[2] <= 1'b0;
  #10 KEY[2] <= 1'b1;
end // initial

blackjack_top n(CLOCK_50, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

endmodule