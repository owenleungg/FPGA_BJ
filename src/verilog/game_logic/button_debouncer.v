module slow_clock(
    input CLOCK_50,
    output reg clk_out
);
    reg[15:0] count = 0;  // Reduced counter size
    parameter DIVISOR = 16'd50000;  // 1ms with 50MHz clock

    always @(posedge CLOCK_50)
    begin 
        if (count == DIVISOR - 1) begin
            count <= 0;
            clk_out <= ~clk_out;
        end
        else begin
            count <= count + 1;
        end
    end
endmodule

module button_debouncer(
    input button,
    input CLOCK_50,
    output button_pressed
);
    wire clk_out;
    wire Q1, Q2, Q2bar;
    reg prev_output;
    reg [1:0] stable_count;
    
    // Generate slow clock for sampling
    slow_clock u1(CLOCK_50, clk_out);
    
    // Two flip-flops for meta-stability and debouncing
    D_FF d1(clk_out, button, Q1);
    D_FF d2(clk_out, Q1, Q2);

    assign Q2bar = ~Q2;
    wire raw_press = Q1 & Q2bar;
    
    // Additional stability checking
    always @(posedge clk_out) begin
        if (raw_press != prev_output) begin
            stable_count <= 2'b00;
            prev_output <= raw_press;
        end
        else if (stable_count != 2'b11) begin
            stable_count <= stable_count + 1;
        end
    end
    
    // Only output press when signal has been stable
    assign button_pressed = raw_press & (stable_count == 2'b11);
endmodule   

module D_FF(
    input clk,
    input D,
    output reg Q,
    output reg Qbar
);
    always @(posedge clk) begin  
        Q <= D;
        Qbar <= ~D;  // Changed to directly use D
    end
endmodule