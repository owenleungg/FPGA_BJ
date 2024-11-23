module blackjack_ps2 (
    // Inputs
    input wire CLOCK_50,
    input wire reset,         // Active-high reset
    
    // Bidirectionals
    inout PS2_CLK,
    inout PS2_DAT,
    
    // Outputs
    output reg hit_pressed,
    output reg stand_pressed,
    output reg deal_pressed,
    output wire [9:0] LEDR    // For debugging - shows last key pressed
);

    // Internal signals
    wire [7:0] ps2_key_data;
    wire ps2_key_pressed;
    reg [7:0] last_data_received;

    // PS2 scan codes for H, S, and D keys
    localparam H_KEY = 8'h33;  // PS2 scan code for H
    localparam S_KEY = 8'h1B;  // PS2 scan code for S
    localparam D_KEY = 8'h23;  // PS2 scan code for D

	// raw signals
	reg hit_raw;
	reg stand_raw;
	reg deal_raw;

    // Store last received data for debugging display
    always @(posedge CLOCK_50) begin
        if (reset)
            last_data_received <= 8'h00;
        else if (ps2_key_pressed)
            last_data_received <= ps2_key_data;
    end

    // Process key presses
    always @(posedge CLOCK_50) begin
        if (reset) begin
            hit_raw <= 1'b0;
            stand_raw <= 1'b0;
            deal_raw <= 1'b0;
        end
        else begin
            // Default all signals to 0
            hit_raw <= 1'b0;
            stand_raw <= 1'b0;
            deal_raw <= 1'b0;

            // Set appropriate signal based on key press
            if (ps2_key_pressed) begin
                case (ps2_key_data)
                    H_KEY: hit_raw <= 1'b1;
                    S_KEY: stand_raw <= 1'b1;
                    D_KEY: deal_raw <= 1'b1;
                endcase
            end
        end
    end

    // Debug display - show last key pressed on LEDs
    assign LEDR[7:0] = last_data_received;

	button_debouncer hit_key (
        .button(hit_raw),
        .CLOCK_50(CLOCK_50),
        .button_pressed(hit_pressed)
    );

		button_debouncer stand_key (
        .button(stand_raw),
        .CLOCK_50(CLOCK_50),
        .button_pressed(stand_pressed)
    );

		button_debouncer deal_key (
        .button(deal_raw),
        .CLOCK_50(CLOCK_50),
        .button_pressed(deal_pressed)
    );

    // Instantiate the PS2 Controller
    PS2_Controller PS2 (
        .CLOCK_50(CLOCK_50),
        .reset(reset),              // Connect reset
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(ps2_key_data),
        .received_data_en(ps2_key_pressed)
    );

endmodule