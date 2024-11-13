module currency_updaters (current_currency, currency_change);
    input [7:0] SW;
    input [1:0] KEY;
    output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    output [9:0] LEDR;
  
    reg [7:0] A, B;
    wire [7:0] S;
    wire cout;


    // Store SW value into A or B based on KEY
    always @(posedge KEY[0]) 
    begin
        if (KEY[1] == 1'b0)
            A <= SW;
        else
            B <= SW;
    end

    // Connect the result to LEDR
    assign LEDR[7:0] = S;
    assign LEDR[8] = cout;

    full_adder16 U1 (A, B, 1'b0, S, cout);

endmodule

module full_adder (A, B, cin, S, cout);
    input A, B, cin;
    output S, cout;

    assign S = A ^ B ^ cin;
    assign cout = (B & A) | (A & cin) | (B & cin);
endmodule

module full_adder8 (A,B,cin,S,cout);

   input[7:0] A,B;
   input cin;
   output [7:0] S;
   output cout;

   wire c[7:0];
   assign c[0] = cin;

   full_adder U1 (A[0], B[0], c[0], S[0], c[1]);
   full_adder U2 (A[1], B[1], c[1], S[1], c[2]);
   full_adder U3 (A[2], B[2], c[2], S[2], c[3]);
   full_adder U4 (A[3], B[3], c[3], S[3], c[4]);
   full_adder U5 (A[4], B[4], c[4], S[4], c[5]);
   full_adder U6 (A[5], B[5], c[5], S[5], c[6]);
   full_adder U7 (A[6], B[6], c[6], S[6], c[7]);
   full_adder U8 (A[7], B[7], c[7], S[7], cout);
endmodule

module comparator (V, c, z);
    input [3:0] V; 
    input c;
    output z;

    assign z = (V[3] & V[2]) | (V[3] & V[1]) | c;
endmodule

module mux_4bit (cout, M);
    input cout;
    output [3:0] M; 

    assign M[0] = 0;
    assign M[1] = cout;
    assign M[2] = cout;
    assign M[3] = 0;
endmodule

