module button_debouncer(
    input button,
    input CLOCK_50,
    output button_pressed
);

    wire clk_out;
    wire Q1, Q2, Q2bar;

    slow_clock u1(CLOCK_50, clk_out);
    D_FF d1(clk_out, button, Q1);
    D_FF d2(clk_out, Q1, Q2);

    assign Q2bar = ~Q2;
    assign button_pressed = Q1 & Q2bar;

endmodule

module slow_clock(
    input CLOCK_50,
    output reg clk_out,
);
    reg[16:0] count = 0;

    always @(posedge CLOCK_50)
    begin 
        count <= count + 1;
        if (count == 16'b1)
            begin
                count <=0;
                clk_out = ~clk_out;
            end
    end

endmodule

module D_FF(
    input clk, // slow clock input
    input D,
    output reg Q,
    output reg Qbar
);

    always @ (posedge clk)
    begin  
        Q <= D;
        Qbar <= ~Q;
    end


endmodule
