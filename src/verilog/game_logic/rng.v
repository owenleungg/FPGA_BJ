module rng (CLOCK_50, a_key_pressed, HEX0, HEX1);
  input wire CLOCK_50;  // 50MHz clock input
  input wire a_key_pressed;   // a_key_pressed for new number, KEY[1] for zero display
  output wire [6:0] HEX0, HEX1;

  // Internal signals
  reg [4:0] lfsr;         // 5-bit LFSR
  reg [3:0] random_num;   // Current random number (1-11)
  wire feedback;          // LFSR feedback signal
   
  // Debouncing counters and signals
  reg [19:0] key_counter;  // 20-bit counter for debouncing
  reg key_was_pressed;     // Key state tracker
  wire key_pressed;        // Debounced key press signal
   
  // XNOR feedback for maximum length sequence
  assign feedback = ~(lfsr[4] ^ lfsr[2]);  // Taps at positions 5 and 3
   
  // Debouncing logic for a_key_pressed
  assign key_pressed = (key_counter == 20'hFFFFF) && !key_was_pressed;
   
  // Counter logic for debouncing a_key_pressed
  always @(posedge CLOCK_50) begin
    if (a_key_pressed) begin  // Key not pressed (remember, keys are active low)
      key_counter <= 20'd0;
        key_was_pressed <= 1'b0;
    end
    else begin  // Key is pressed
      if (key_counter != 20'hFFFFF)
        key_counter <= key_counter + 1'b1;
      else
      key_was_pressed <= 1'b1;
    end
  end
   
  // Signals for decimal digit separation
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
   
  // Instantiate 7-segment decoders for both digits
  char_7seg ones_display(ones, HEX0);
  char_7seg tens_display(tens, HEX1);
   
  // LFSR with synchronous reset
  always @(posedge CLOCK_50) begin
    if (~KEY[1]) begin  // Reset using KEY[1]
      lfsr <= 5'b00010;  // Initialize with non-zero value
      random_num <= 4'd1;
    end
    else if (key_pressed) begin  // Generate new number on debounced key press
      lfsr <= {lfsr[3:0], feedback};
                       
    // Map LFSR value to 1-11 range
    if (lfsr[3:0] < 4'd11)
      random_num <= lfsr[3:0] + 4'd1;
    else
      random_num <= 4'd1;  // If out of range, wrap to 1
    end
  end


endmodule

module char_7seg(
    input [3:0] M,
    output [6:0] Display
);
    assign Display[0] = ((~M[3]& ~M[2]& ~M[1]& M[0]) | (M[2]& ~M[1]& ~M[0]));
    assign Display[1] = ((M[2]& ~M[1]& M[0]) | (M[2]& M[1]& ~M[0]));
    assign Display[2] = ((~M[2]& M[1]& ~M[0]));
    assign Display[3] = ((M[2]& ~M[1]& ~M[0]) | (~M[2]& ~M[1]& M[0]) | (M[3]& M[0]) | (M[2]& M[1]& M[0]));
    assign Display[4] = ((~M[3]& M[0]) | (~M[3]& M[2]& ~M[1]) | (M[3]& M[0]));
    assign Display[5] = ((~M[2]& M[1]& ~M[0]) | (~M[3]& ~M[2]& M[0]) | (M[1]& M[0]));
    assign Display[6] = ((~M[3]& ~M[2]& ~M[1]) | (M[2]& M[1]& M[0]));
endmodule
