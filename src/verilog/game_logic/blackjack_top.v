// Top-level module
module blackjack_top (
    input wire CLOCK_50,
    input wire [3:0] KEY,          // KEY[0]=hit, KEY[1]=stand, KEY[2]=reset, KEY[3]=start/deal
    output wire [6:0] HEX0,        // Player score ones digit
    output wire [6:0] HEX1,        // Player score tens digit
    output wire [6:0] HEX2,        // Dealer score ones digit
    output wire [6:0] HEX3,        // Dealer score tens digit
    output wire [6:0] HEX4,        // Status display (P/d/b/t)
    output wire [6:0] HEX5         // Game state indicator
);

    // Internal connections
    wire [3:0] card_value;
    wire [4:0] player_score, dealer_score;
    wire [2:0] game_state;
    reg hit_pressed, stand_pressed, deal_pressed;
    wire [3:0] player_ones, player_tens, dealer_ones, dealer_tens;
    wire show_dealer_first;

    // PS/2 Controller signals
    wire ps2_clk;
    wire ps2_dat;
    wire [7:0] received_data;
    wire received_data_en;
    wire command_was_sent;
    wire error_communication_timed_out;
    wire [7:0] the_command = 8'h00; // Default command not used here
    wire send_command = 1'b0;      // No commands sent in this design

    // RNG Module
    card_rng rng_inst (
        .clk(CLOCK_50),
        .card_value(card_value)
    );

    //Button debouncer
    button_debouncer debouncer_inst (
        .clk(CLOCK_50),
        .rst_n(KEY[2]),
        .key_hit(KEY[0]),
        .key_stand(KEY[1]),
        .key_deal(KEY[3]),
        .hit_pressed(hit_pressed),
        .stand_pressed(stand_pressed),
        .deal_pressed(deal_pressed)
    );

    // Main game FSM
    blackjack_fsm fsm_inst (
        .clk(CLOCK_50),
        .rst_n(KEY[2]),
        .hit_pressed(hit_pressed),
        .stand_pressed(stand_pressed),
        .deal_pressed(deal_pressed),
        .card_value(card_value),
        .player_score(player_score),
        .dealer_score(dealer_score),
        .game_state(game_state),
        .show_dealer_first(show_dealer_first)
    );

    // Score to digit converter
    score_converter score_conv_inst (
        .player_score(player_score),
        .dealer_score(dealer_score),
        .show_dealer_first(show_dealer_first),
        .player_ones(player_ones),
        .player_tens(player_tens),
        .dealer_ones(dealer_ones),
        .dealer_tens(dealer_tens)
    );

    // Display modules
    display_controller display_inst (
        .game_state(game_state),
        .player_score(player_score),
        .dealer_score(dealer_score),
        .player_ones(player_ones),
        .player_tens(player_tens),
        .dealer_ones(dealer_ones),
        .dealer_tens(dealer_tens),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

    // Instantiate the PS/2 Controller
    PS2_Controller ps2_controller_inst (
        .CLOCK_50(CLOCK_50),
        .reset(KEY[2]),

        .the_command(the_command),
        .send_command(send_command),

        .PS2_CLK(ps2_clk),
        .PS2_DAT(ps2_dat),

        .command_was_sent(command_was_sent),
        .error_communication_timed_out(error_communication_timed_out),

        .received_data(received_data),
        .received_data_en(received_data_en)
    );

    // Keyboard input mapping
    always @(posedge CLOCK_50 or posedge KEY[2]) begin
        if (KEY[2]) begin
            hit_pressed <= 1'b0;
            stand_pressed <= 1'b0;
            deal_pressed <= 1'b0;
        end else if (received_data_en) begin
            case (received_data)
                8'h23: hit_pressed <= 1'b1;   // Example key for hit (e.g., "H" key)
                8'h1B: stand_pressed <= 1'b1; // Example key for stand (e.g., "S" key)
                8'h2D: deal_pressed <= 1'b1;  // Example key for deal (e.g., "D" key)
                default: begin
                    hit_pressed <= 1'b0;
                    stand_pressed <= 1'b0;
                    deal_pressed <= 1'b0;
                end
            endcase
        end
    end
    

endmodule


