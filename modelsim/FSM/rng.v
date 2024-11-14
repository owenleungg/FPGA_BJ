module rng (
  input wire CLOCK_50,           // 50MHz clock input
  input wire [1:0] KEY,          // KEY[0]: new number, KEY[1]: reset (active-low)
  output reg [3:0] current_card    // Current randomly generated card
);

  // Internal signals
  reg [4:0] lfsr = 5'b00010;     // 5-bit LFSR with non-zero initial state
  wire feedback;                 // LFSR feedback signal

  // Feedback for maximal length sequence (taps at positions 5 and 3)
  assign feedback = ~(lfsr[4] ^ lfsr[2]);

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
