module RNG (
  input wire CLOCK_50,           // 50MHz clock input
  input wire [1:0] KEY,          // KEY[0]: new number, KEY[1]: reset (active-low)
  output wire [6:0] HEX0, HEX1
);

  // Internal signals
  reg [4:0] lfsr = 5'b00010;     // 5-bit LFSR with non-zero initial state
  reg [3:0] random_num;          // Current random number (1-11)
  wire feedback;                 // LFSR feedback signal

  // Debounce signals
  reg [19:0] key_counter = 20'd0;
  reg key_was_pressed = 1'b0;
  wire key_pressed;

  // Feedback for maximal length sequence (taps at positions 5 and 3)
  assign feedback = ~(lfsr[4] ^ lfsr[2]);

  // Debouncing logic for KEY[0]
  assign key_pressed = (key_counter == 20'hFFFFF) && !key_was_pressed;

  // Debounce counter for KEY[0]
  always @(posedge CLOCK_50) begin
    if (KEY[0]) begin
      key_counter <= 20'd0;
      key_was_pressed <= 1'b0;
    end
    else begin
      if (key_counter != 20'hFFFFF)
        key_counter <= key_counter + 1;
      else
        key_was_pressed <= 1'b1;
    end
  end

  // Separate ones and tens for the 7-segment display
  reg [3:0] ones;
  reg [3:0] tens;
  always @(*) begin
    if (random_num <= 4'd9) begin
      ones = random_num;
      tens = 4'd0;
    end else begin
      ones = random_num - 4'd10;
      tens = 4'd1;
    end
  end

  // 7-segment decoders for both digits
  char_7seg ones_display(ones, HEX0);
  char_7seg tens_display(tens, HEX1);

  // LFSR with reset and new number generation
  always @(posedge CLOCK_50) begin
    if (~KEY[1]) begin  // Reset when KEY[1] is pressed (active low)
      lfsr <= 5'b00010;
      random_num <= 4'd1;
    end else if (key_pressed) begin  // Generate new number on debounced press
      lfsr <= {lfsr[3:0], feedback};

      // Map LFSR output to range 1-11
      if (lfsr[3:0] < 4'd11)
        random_num <= lfsr[3:0] + 4'd1;
      else
        random_num <= 4'd1;
    end
  end

endmodule

// Module for 7-segment display decoder
module char_7seg(
    input [3:0] M, 
    output [6:0] Display
);
  assign Display[0] = (~M[3] & ~M[2] & ~M[1] & M[0]) | (M[2] & ~M[1] & ~M[0]);
  assign Display[1] = (M[2] & ~M[1] & M[0]) | (M[2] & M[1] & ~M[0]);
  assign Display[2] = (~M[2] & M[1] & ~M[0]);
  assign Display[3] = (M[2] & ~M[1] & ~M[0]) | (~M[2] & ~M[1] & M[0]) | (M[3] & M[0]) | (M[2] & M[1] & M[0]);
  assign Display[4] = (~M[3] & M[0]) | (~M[3] & M[2] & ~M[1]) | (M[3] & M[0]);
  assign Display[5] = (~M[2] & M[1] & ~M[0]) | (~M[3] & ~M[2] & M[0]) | (M[1] & M[0]);
  assign Display[6] = (~M[3] & ~M[2] & ~M[1]) | (M[2] & M[1] & M[0]);
endmodule
