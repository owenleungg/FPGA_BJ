module top (input CLOCK_50, input reset, output [6:0] HEX0, HEX1);
    wire a_key_pressed;
    wire [7:0] received_data;
    wire received_data_en;
    
    // Instantiate PS2_Controller
    PS2_Controller ps2_inst (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .received_data(received_data),
        .received_data_en(received_data_en),
        .a_key_pressed(a_key_pressed)
    );
    
    // Instantiate RNG and connect a_key_pressed
    rng rng_inst (
        .CLOCK_50(CLOCK_50),
        .a_key_pressed(a_key_pressed),
        .HEX0(HEX0),
        .HEX1(HEX1)
    );
endmodule