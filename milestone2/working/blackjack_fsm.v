// Main game FSM
module blackjack_fsm (
    input wire clk,
    input wire rst_n,
    input wire hit_pressed,
    input wire stand_pressed,
    input wire deal_pressed,
    input wire [3:0] card_value,
    output reg [4:0] player_score,
    output reg [4:0] dealer_score,
    output reg [2:0] game_state,
    output reg show_dealer_first
);
    // State definitions
    localparam IDLE = 3'b000;
    localparam DEALING = 3'b001;
    localparam PLAYER_TURN = 3'b010;
    localparam DEALER_TURN = 3'b011;
    localparam GAME_OVER = 3'b100;

    // Internal registers
    reg [2:0] cards_dealt;
    reg [4:0] player_first_two;
    reg [4:0] dealer_first_two;
	 reg [4:0] new_score;
    reg player_has_ace;
    reg dealer_has_ace;
    reg dealing_complete;
    reg player_busted;  // Register to track player bust
    
    function [4:0] adjust_for_ace;
        input [4:0] current_score;
        input [3:0] new_card;
        input has_ace;
        begin
            if (new_card == 4'd1) begin  // New card is Ace
                if (current_score <= 10)
                    adjust_for_ace = current_score + 11;
                else
                    adjust_for_ace = current_score + 1;
            end
            else if (has_ace && (current_score + new_card > 21))
                adjust_for_ace = current_score - 10 + new_card;  // Convert Ace from 11 to 1
            else
                adjust_for_ace = current_score + new_card;
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            game_state <= IDLE;
            player_score <= 5'd0;
            dealer_score <= 5'd0;
            cards_dealt <= 3'd0;
            player_first_two <= 5'd0;
            dealer_first_two <= 5'd0;
            player_has_ace <= 1'b0;
            dealer_has_ace <= 1'b0;
            show_dealer_first <= 1'b0;
            dealing_complete <= 1'b0;
            player_busted <= 1'b0;
        end
        else begin
            case (game_state)
                IDLE: begin
                    if (deal_pressed) begin
                        game_state <= DEALING;
                        cards_dealt <= 3'd0;
                        player_score <= 5'd0;
                        dealer_score <= 5'd0;
                        player_first_two <= 5'd0;
                        dealer_first_two <= 5'd0;
                        player_has_ace <= 1'b0;
                        dealer_has_ace <= 1'b0;
                        show_dealer_first <= 1'b0;
                        dealing_complete <= 1'b0;
                        player_busted <= 1'b0;
                    end
                end

                DEALING: begin
                    if (!dealing_complete) begin
                        case (cards_dealt)
                            3'd0: begin  // First player card
                                player_first_two <= adjust_for_ace(5'd0, card_value, 1'b0);
                                player_score <= adjust_for_ace(5'd0, card_value, 1'b0);
                                if (card_value == 4'd1) player_has_ace <= 1'b1;
                                cards_dealt <= cards_dealt + 1'b1;
                            end
                            3'd1: begin  // First dealer card
                                dealer_first_two <= adjust_for_ace(5'd0, card_value, 1'b0);
                                dealer_score <= adjust_for_ace(5'd0, card_value, 1'b0);
                                if (card_value == 4'd1) dealer_has_ace <= 1'b1;
                                cards_dealt <= cards_dealt + 1'b1;
                                show_dealer_first <= 1'b1;
                            end
                            3'd2: begin  // Second player card
                                player_first_two <= adjust_for_ace(player_first_two, card_value, player_has_ace);
                                player_score <= adjust_for_ace(player_score, card_value, player_has_ace);
                                if (card_value == 4'd1) player_has_ace <= 1'b1;
                                cards_dealt <= cards_dealt + 1'b1;
                            end
                            3'd3: begin  // Second dealer card
                                dealer_first_two <= adjust_for_ace(dealer_first_two, card_value, dealer_has_ace);
                                dealer_score <= adjust_for_ace(dealer_score, card_value, dealer_has_ace);
                                if (card_value == 4'd1) dealer_has_ace <= 1'b1;
                                dealing_complete <= 1'b1;
                            end
                        endcase
                    end
                    else begin
                        // Check for initial blackjack
                        if (player_first_two == 5'd21) begin
                            if (dealer_first_two == 5'd21)
                                game_state <= GAME_OVER;  // Push
                            else
                                game_state <= GAME_OVER;  // Player wins with blackjack
                        end
                        else if (dealer_first_two == 5'd21)
                            game_state <= GAME_OVER;  // Dealer wins with blackjack
                        else
                            game_state <= PLAYER_TURN;
                    end
                end

                PLAYER_TURN: begin
                    if (hit_pressed) begin
   
                        new_score = adjust_for_ace(player_score, card_value, player_has_ace);
                        if (card_value == 4'd1) player_has_ace <= 1'b1;
                        player_score <= new_score;
                        
                        // Immediate bust check
                        if (new_score > 21) begin
                            player_busted <= 1'b1;
                            game_state <= GAME_OVER;
                        end
                    end
                    else if (stand_pressed)
                        game_state <= DEALER_TURN;
                end

                DEALER_TURN: begin
                    show_dealer_first <= 1'b1;
                    // Only continue dealer's turn if player hasn't busted
                    if (!player_busted) begin
                        if (dealer_score < 17) begin
                            dealer_score <= adjust_for_ace(dealer_score, card_value, dealer_has_ace);
                            if (card_value == 4'd1) dealer_has_ace <= 1'b1;
                        end
                        else
                            game_state <= GAME_OVER;
                    end
                    else
                        game_state <= GAME_OVER;
                end

                GAME_OVER: begin
                    if (deal_pressed)  // New game
                        game_state <= IDLE;
                end
            endcase
        end
    end
endmodule

// Score converter module
module score_converter (
    input wire [4:0] player_score,
    input wire [4:0] dealer_score,
    input wire show_dealer_first,
    output wire [3:0] player_ones,
    output wire [3:0] player_tens,
    output wire [3:0] dealer_ones,
    output wire [3:0] dealer_tens
);
    assign player_ones = player_score % 10;
    assign player_tens = player_score / 10;
    assign dealer_ones = show_dealer_first ? dealer_score % 10 : 4'h0;
    assign dealer_tens = show_dealer_first ? dealer_score / 10 : 4'h0;
endmodule

// Display controller module
module display_controller (
    input wire [2:0] game_state,
    input wire [4:0] player_score,
    input wire [4:0] dealer_score,
    input wire [3:0] player_ones,
    input wire [3:0] player_tens,
    input wire [3:0] dealer_ones,
    input wire [3:0] dealer_tens,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);
    // Seven segment display instances
    char_7seg player_ones_display(player_ones, HEX0);
    char_7seg player_tens_display(player_tens, HEX1);
    char_7seg dealer_ones_display(dealer_ones, HEX2);
    char_7seg dealer_tens_display(dealer_tens, HEX3);

    // Status display logic
    reg [6:0] status_display;
    always @(*) begin
        case (game_state)
            3'b000: status_display = 7'b1111111;      // Blank (IDLE)
            3'b001: status_display = 7'b0100001;      // d (INITIAL_DEAL)
            3'b010: status_display = 7'b0001100;      // P (PLAYER_TURN)
            3'b011: status_display = 7'b0100001;      // d (DEALER_TURN)
            3'b100: begin                             // GAME_OVER
                if (player_score > 21)
                    status_display = 7'b0000011;      // b (bust)
                else if (dealer_score > 21)
                    status_display = 7'b0001100;      // P (player wins)
                else if (player_score == dealer_score)
                    status_display = 7'b0001111;      // t (tie/push)
                else if (player_score > dealer_score)
                    status_display = 7'b0001100;      // P (player wins)
                else
                    status_display = 7'b0100001;      // d (dealer wins)
            end
            default: status_display = 7'b1111111;     // Blank
        endcase
    end
    assign HEX4 = status_display;

    // Game state indicator
    assign HEX5 = (game_state == 3'b000) ? 7'b1111001 :     // 1 (IDLE)
                  (game_state == 3'b001) ? 7'b0100100 :      // 2 (INITIAL_DEAL)
                  (game_state == 3'b010) ? 7'b0110000 :      // 3 (PLAYER_TURN)
                  (game_state == 3'b011) ? 7'b0011001 :      // 4 (DEALER_TURN)
                  7'b0010010;                                 // 5 (GAME_OVER)
endmodule