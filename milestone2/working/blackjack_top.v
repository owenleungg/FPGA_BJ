// Top-level module
module blackjack_top (
    input wire CLOCK_50,
    input wire [2:0] KEY,          // KEY[0]=hit, KEY[1]=stand, KEY[2]=reset, KEY[3]=start/deal
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

    // Replaced Debouncer
    always @ (*)
    begin
        hit_pressed <= KEY[0];
        stand_pressed <= KEY[1];
        deal_pressed <= KEY [2];
    end
        
    
    // RNG Module
    card_rng rng_inst (
        .clk(CLOCK_50),
        .card_value(card_value)
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

endmodule


