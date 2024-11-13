`timescale 1ns/1ps

module testbench;

  reg CLOCK_50;
  reg [1:0] KEY;
  wire [6:0] HEX0, HEX1;

  // Instantiate the RNG module
  rng uut (
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .HEX0(HEX0),
    .HEX1(HEX1)
  );

  // Generate a 50 MHz clock (20 ns period)
  initial begin
    CLOCK_50 = 0;
    forever #10 CLOCK_50 = ~CLOCK_50;
  end

  // Test sequence
  initial begin
    // Initialize inputs
    KEY = 2'b11; // No reset, no key press (active high)

    // Wait for a few clock cycles to stabilize
    #100;

    // Press KEY[0] five times to generate random numbers
    repeat (5) begin
      KEY[0] = 0;      // Press KEY[0] (active low)
      #25000000;       // Hold for 25 ms to ensure debounce
      KEY[0] = 1;      // Release KEY[0]
      #10000000;       // Wait 10 ms before the next press
    end

    // Apply reset with KEY[1]
    KEY[1] = 0;        // Active low reset
    #25000000;         // Hold reset for 25 ms
    KEY[1] = 1;        // Release reset
    #10000000;         // Wait to observe the reset effect

    // End simulation
    #50000000;         // Observe output for 50 ms
    $finish;
  end

  // Monitor output
  initial begin
    $monitor("Time=%0dns KEY[1]=%b KEY[0]=%b HEX1=%b HEX0=%b",
             $time, KEY[1], KEY[0], HEX1, HEX0);
  end

endmodule