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
