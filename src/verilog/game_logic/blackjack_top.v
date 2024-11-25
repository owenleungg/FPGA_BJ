module blackjack_top (
    // PS2 Interface
    inout PS2_CLK,
    inout PS2_DAT,

    // Clock and Reset
    input wire CLOCK_50,
    input wire [3:0] KEY,         

    // Display outputs
    output wire [6:0] HEX0,        
    output wire [6:0] HEX1,        
    output wire [6:0] HEX2,        
    output wire [6:0] HEX3,        
    output wire [6:0] HEX4,        
    output wire [6:0] HEX5,        
    output wire [9:0] LEDR,        

    // VGA outputs
    output [7:0] VGA_R,      
    output [7:0] VGA_G,      
    output [7:0] VGA_B,      
    output VGA_HS,           
    output VGA_VS,           
    output VGA_BLANK_N,      
    output VGA_SYNC_N,       
    output VGA_CLK           
);
    // Internal connections
    wire [3:0] card_value;
    wire [4:0] player_score, dealer_score;
    wire [2:0] game_state;
    wire hit_pressed, stand_pressed, deal_pressed;
    wire [3:0] player_ones, player_tens, dealer_ones, dealer_tens;
    wire show_dealer_first;
    //wire dealer_turn;
    
    // Initial card values
    wire [3:0] dealer_init_card_1;
    wire [3:0] dealer_init_card_2;
    wire [3:0] player_init_card_1;
    wire [3:0] player_init_card_2;
	 
	 wire deal_player_card_1;

    // Assign dealer_turn based on game state
    assign dealer_turn = (game_state == 3'b011); // DEALER_TURN state
     
    // PS2 controller
    blackjack_ps2 ps2_inst (
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .CLOCK_50(CLOCK_50),
        .reset(~KEY[0]),          
        .hit_pressed(hit_pressed),
        .stand_pressed(stand_pressed),
        .deal_pressed(deal_pressed)
    );

    // Card RNG
    card_rng rng_inst (
        .clk(CLOCK_50),
        .rst_n(KEY[0]), 
        .card_value(card_value)
    );

    // Game FSM
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
        .show_dealer_first(show_dealer_first),
		  .deal_player_card_1(deal_player_card_1)
    );

    // Score converter
    score_converter score_conv_inst (
        .player_score(player_score),
        .dealer_score(dealer_score),
        .show_dealer_first(show_dealer_first),
        .player_ones(player_ones),
        .player_tens(player_tens),
        .dealer_ones(dealer_ones),
        .dealer_tens(dealer_tens)
    );

    // Display controller
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

    // VGA controller
    vga_blackjack vga_inst (
        .CLOCK_50(CLOCK_50),                     
        .hit_pressed(hit_pressed),    
        .deal_pressed(deal_pressed),   
        .card_value(card_value),  
        .KEY(KEY[0]),       
        .VGA_R(VGA_R),             
        .VGA_G(VGA_G),           
        .VGA_B(VGA_B),             
        .VGA_HS(VGA_HS),          
        .VGA_VS(VGA_VS),           
        .VGA_BLANK_N(VGA_BLANK_N), 
        .VGA_SYNC_N(VGA_SYNC_N),   
        .VGA_CLK(VGA_CLK),    
        .LEDR(LEDR),
        .game_state(game_state)   
    );
endmodule