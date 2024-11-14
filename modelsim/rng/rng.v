module rng (
  input wire CLOCK_50,           // 50MHz clock input
  input wire [1:0] KEY,          // KEY[0]: new number, KEY[1]: reset (active-low)
  output wire [6:0] HEX0, HEX1
);

  // Internal signals
  reg [4:0] lfsr = 5'b00010;     // 5-bit LFSR with non-zero initial state
  reg [3:0] current_card;          // Current random number (1-11)
  wire feedback;                 // LFSR feedback signal

  // Feedback for maximal length sequence (taps at positions 5 and 3)
  assign feedback = ~(lfsr[4] ^ lfsr[2]);

  // Separate ones and tens for the 7-segment display
  reg [3:0] ones;
  reg [3:0] tens;
  always @(*) begin
    if (current_card <= 4'd9) begin
      ones = current_card;
      tens = 4'd0;
    end else begin
      ones = current_card - 4'd10;
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
      current_card <= 4'd0;
    end 
    else begin 
      lfsr <= {lfsr[3:0], feedback};
      // Map LFSR output to range 1-11
      if (lfsr[3:0] < 4'd11)
        current_card <= lfsr[3:0] + 4'd1;
      else
        current_card <= 4'd1;
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
