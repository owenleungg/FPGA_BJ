module blackjack_top (
    // PS2 Interface
    inout PS2_CLK,
    inout PS2_DAT,

    // Clock and Reset
    input wire CLOCK_50,
    input wire [0:0] KEY,         // KEY[0] is reset, active-low

    // Display outputs
    output wire [6:0] HEX0,        // Player score ones digit
    output wire [6:0] HEX1,        // Player score tens digit
    output wire [6:0] HEX2,        // Dealer score ones digit
    output wire [6:0] HEX3,        // Dealer score tens digit
    output wire [6:0] HEX4,        // Status display (P/d/b/t)
    output wire [6:0] HEX5,        // Game state indicator
    output wire [9:0] LEDR         // Debug display for PS2
);

    // Internal connections
    wire [3:0] card_value;
    wire [4:0] player_score, dealer_score;
    wire [2:0] game_state;
    wire hit_pressed, stand_pressed, deal_pressed;
    wire hit_raw;
    wire [3:0] player_ones, player_tens, dealer_ones, dealer_tens;
    wire show_dealer_first;

    // Instantiate the PS/2 module 
    blackjack_ps2 ps2_inst (
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .CLOCK_50(CLOCK_50),
        .reset(~KEY[0]),           // Active-high reset to PS2 controller 
        .hit_pressed(hit_raw),
        .stand_pressed(stand_pressed),
        .deal_pressed(deal_pressed),
        .LEDR(LEDR)
    );

    button_debouncer hit_key (
        .button(hit_raw),
        .CLOCK_50(CLOCK_50),
        .button_pressed(hit_pressed)
    )

    // // Button debouncer
    // button_debouncer debouncer_inst (
    //     .clk(CLOCK_50),
    //     .rst_n(KEY[2]), 
    //     .key_hit(KEY[0]),
    //     .key_stand(KEY[1]),
    //     .key_deal(KEY[3]),
    //     .hit_pressed(hit_pressed),
    //     .stand_pressed(stand_pressed),
    //     .deal_pressed(deal_pressed)
    // );

    // RNG Module
    card_rng rng_inst (
        .clk(CLOCK_50),
        .rst_n(KEY[0]), 
        .card_value(card_value)
    );

    // Main game FSM
    blackjack_fsm fsm_inst (
        .clk(CLOCK_50),
        .rst_n(KEY[0]),   
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