module blackjack_ps2 (
    input wire CLOCK_50,
    input wire reset,
    
    inout PS2_CLK,
    inout PS2_DAT,
    
    output reg hit_pressed,
    output reg stand_pressed,
    output reg deal_pressed,
    output wire [9:0] LEDR
);

    // Internal signals
    wire [7:0] ps2_key_data;
    wire ps2_key_pressed;
    reg [7:0] last_data_received;
    reg waiting_for_break;
    
    // Add state tracking for key handling
    reg [7:0] last_valid_key;
    reg key_handled;

    // PS2 scan codes
    localparam H_KEY = 8'h33;    // H key
    localparam S_KEY = 8'h1B;    // S key
    localparam D_KEY = 8'h23;    // D key
    localparam BREAK = 8'hF0;    // Break code

    // Handle PS2 input
    always @(posedge CLOCK_50) begin
        if (reset) begin
            hit_pressed <= 1'b0;
            stand_pressed <= 1'b0;
            deal_pressed <= 1'b0;
            waiting_for_break <= 1'b0;
            last_data_received <= 8'h00;
            last_valid_key <= 8'h00;
            key_handled <= 1'b0;
        end
        else begin
            // Default all signals to 0 every clock cycle
            hit_pressed <= 1'b0;
            stand_pressed <= 1'b0;
            deal_pressed <= 1'b0;

            if (ps2_key_pressed) begin
                if (ps2_key_data == BREAK) begin
                    waiting_for_break <= 1'b1;
                    key_handled <= 1'b0;
                end
                else if (waiting_for_break) begin
                    waiting_for_break <= 1'b0;
                    last_valid_key <= 8'h00;
                end
                else if (!key_handled) begin  // Only process key if not already handled
                    last_data_received <= ps2_key_data;
                    case (ps2_key_data)
                        H_KEY: begin 
                            hit_pressed <= 1'b1;
                            key_handled <= 1'b1;
                        end
                        S_KEY: begin
                            stand_pressed <= 1'b1;
                            key_handled <= 1'b1;
                        end
                        D_KEY: begin
                            deal_pressed <= 1'b1;
                            key_handled <= 1'b1;
                        end
                    endcase
                end
            end
        end
    end

    // Debug display
    assign LEDR = {key_handled, waiting_for_break, last_data_received};

    // PS2 Controller instance
    PS2_Controller PS2 (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(ps2_key_data),
        .received_data_en(ps2_key_pressed)
    );

endmodule