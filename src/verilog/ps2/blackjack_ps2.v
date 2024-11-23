module blackjack_ps2 (
    // Inputs
    input wire CLOCK_50,
    input wire reset,
    
    // Bidirectionals
    inout PS2_CLK,
    inout PS2_DAT,
    
    // Outputs
    output reg hit_pressed,
    output reg stand_pressed,
    output reg deal_pressed,
    output wire [7:0] received_data,  // Debug: raw PS2 data
    output wire received_valid,       // Debug: data valid signal
    output wire [9:0] LEDR           // Debug display
);

    // Internal signals
    wire [7:0] ps2_key_data;
    wire ps2_key_pressed;
    reg [7:0] last_data_received;
    reg key_released;  // Track if key was released

    // PS2 scan codes for make (press) and break (release) codes
    localparam H_MAKE = 8'h33;    // H key make code
    localparam S_MAKE = 8'h1B;    // S key make code
    localparam D_MAKE = 8'h23;    // D key make code
    localparam BREAK = 8'hF0;     // Break code prefix

    // Store last received data for debugging
    always @(posedge CLOCK_50) begin
        if (reset) begin
            last_data_received <= 8'h00;
            key_released <= 1'b0;
        end
        else if (ps2_key_pressed) begin
            if (ps2_key_data == BREAK)
                key_released <= 1'b1;
            else begin
                last_data_received <= ps2_key_data;
                key_released <= 1'b0;
            end
        end
    end

    // Process key presses with break code handling
    always @(posedge CLOCK_50) begin
        if (reset) begin
            hit_pressed <= 1'b0;
            stand_pressed <= 1'b0;
            deal_pressed <= 1'b0;
        end
        else begin
            // Default all signals to 0
            hit_pressed <= 1'b0;
            stand_pressed <= 1'b0;
            deal_pressed <= 1'b0;

            // Only set signals on make codes (not on break codes)
            if (ps2_key_pressed && !key_released) begin
                case (ps2_key_data)
                    H_MAKE: hit_pressed <= 1'b1;
                    S_MAKE: stand_pressed <= 1'b1;
                    D_MAKE: deal_pressed <= 1'b1;
                endcase
            end
        end
    end

    // Debug outputs
    assign received_data = ps2_key_data;
    assign received_valid = ps2_key_pressed;
    assign LEDR = {1'b0, key_released, last_data_received};

    // Instantiate the PS2 Controller
    PS2_Controller PS2 (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(ps2_key_data),
        .received_data_en(ps2_key_pressed)
    );

endmodule