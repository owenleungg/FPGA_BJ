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
    wire [3:0] player_ones, player_tens, dealer_ones, dealer_tens;
    wire show_dealer_first;
    
    // Raw PS2 signals before debouncing
    wire raw_hit, raw_stand, raw_deal;
    
    // Final debounced signals
    wire hit_pressed, stand_pressed, deal_pressed;
        
    // Instantiate the PS/2 module 
    blackjack_ps2 ps2_inst (
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .CLOCK_50(CLOCK_50),
        .reset(~KEY[0]),            // Active-high reset to PS2 controller so keys presses are reset 
        .hit_pressed(raw_hit),   
        .stand_pressed(raw_stand),
        .deal_pressed(raw_deal),
        .LEDR(LEDR)
    );

    // Button debouncer for PS2 signals
    button_debouncer debouncer_inst (
        .clk(CLOCK_50),
        .rst_n(KEY[0]),
        .key_hit(raw_hit),       
        .key_stand(raw_stand),
        .key_deal(raw_deal),
        .hit_pressed(hit_pressed), 
        .stand_pressed(stand_pressed),
        .deal_pressed(deal_pressed)
    );

    // RNG Module
    card_rng rng_inst (
        .clk(CLOCK_50),
        .card_value(card_value)
    );

    // Main game FSM
    blackjack_fsm fsm_inst (
        .clk(CLOCK_50),
        .rst_n(KEY[0]),           // Active low game reset
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