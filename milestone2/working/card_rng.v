// RNG Module for card generation
module card_rng (
    input wire clk,
    output reg [3:0] card_value
);

  // Internal signals
  reg [15:0] lfsr = 15'b00010;     // 5-bit LFSR with non-zero initial state
  wire feedback;    
  
   // Feedback for maximal length sequence (taps at positions 5 and 3)
  assign feedback = lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3];

  // LFSR with reset and new number generation
  always @(posedge clk) begin
  lfsr <= {lfsr[15:0], feedback};
      case (lfsr[3:0])
         4'b0000: card_value <= 4'd1;  // Ace
         4'b0010: card_value <= 4'd2;
         4'b0100: card_value <= 4'd3;
         4'b0001: card_value <= 4'd4;
         4'b0011: card_value <= 4'd5;
         4'b0101: card_value <= 4'd6;
         4'b0110: card_value <= 4'd7;
         4'b0111: card_value <= 4'd8;
         4'b1000: card_value <= 4'd9;
         4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111: card_value <= 4'd10; // 10 or face card
		endcase
   end
endmodule
