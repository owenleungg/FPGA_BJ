module top (
    input wire CLOCK_50,
    input wire [3:0] KEY,           // KEY[0]=hit, KEY[1]=stand, KEY[2]=reset
    output wire [6:0] HEX0, HEX1, HEX2, HEX3,
    output wire dealing_cards,      // Indicates card dealing
    output wire game_finished       // Indicates game over
);

    wire [3:0] current_card;        // Card value from RNG
    wire [4:0] player_score;        // Player score
    wire [4:0] dealer_score;        // Dealer score

    // Split player and dealer scores into tens and ones
    wire [3:0] player_ones = player_score % 10;
    wire [3:0] player_tens = player_score / 10;
    wire [3:0] dealer_ones = dealer_score % 10;
    wire [3:0] dealer_tens = dealer_score / 10;

    // Instantiate the RNG module to generate random card values
    rng rng_inst (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .current_card(current_card)  // Output from rng used as card value
    );

    // Instantiate the FSM module
    blackjack_fsm fsm_inst (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .current_card(current_card),   // Input to FSM from RNG
        .player_score(player_score),
        .dealer_score(dealer_score)
    );

    char_7seg player_ones_display (
        .M(player_ones),
        .Display(HEX0)
    );

    char_7seg player_tens_display (
        .M(player_tens),
        .Display(HEX1)
    );

    // Instantiate char_7seg modules for dealer score (HEX2, HEX3)
    char_7seg dealer_ones_display (
        .M(dealer_ones),
        .Display(HEX2)
    );

    char_7seg dealer_tens_display (
        .M(dealer_tens),
        .Display(HEX3)
    );
endmodule
