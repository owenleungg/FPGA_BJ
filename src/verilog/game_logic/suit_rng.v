module suit_rng (
    input wire clk,
    input wire rst_n,             // Active-low reset
    output reg [1:0] suit
);

  // Internal signals
  reg [15:0] lfsr = 16'b00010;    // 16-bit LFSR 
  wire feedback;

  // Taps positions for feedback
  assign feedback = lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3];

  // LFSR for new number generation
  always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          lfsr <= 16'b00010;      // Reset LFSR 
          suit <= 2'd0;     // Reset card value
      end
      else begin
          lfsr <= {lfsr[14:0], feedback}; 
          case (lfsr[1:0])
              2'b00: suit <= 2'd0;  // diamond
              2'b01: suit <= 2'd1;	// club
              2'b10: suit <= 2'd3;	// heart
              2'b11: suit <= 2'd4;	// spade
			endcase
      end
  end
endmodule
