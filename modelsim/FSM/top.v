module top (
    input wire CLOCK_50,
    input wire [3:0] KEY,           // KEY[0]=hit, KEY[1]=stand, KEY[2]=reset
    output wire HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    wire [3:0] current_card;        // Card value from RNG
    wire [4:0] player_score;        // Player score
    wire [4:0] dealer_score;        // Dealer score

    // Instantiate the FSM module
    blackjack_fsm fsm_inst (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .player_score(player_score),
        .dealer_score(dealer_score),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );
endmodule
