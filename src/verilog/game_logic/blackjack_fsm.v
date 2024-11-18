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
    reg player_has_ace;
    reg dealer_has_ace;
    reg player_ace_converted;  // New register
    reg dealer_ace_converted;  // New register
    reg dealing_complete;
    reg player_busted;
    
    // Wires for ace adjuster outputs
    wire [4:0] player_adjusted_score;
    wire player_new_has_ace;
    wire player_new_ace_converted;
    wire [4:0] dealer_adjusted_score;
    wire dealer_new_has_ace;
    wire dealer_new_ace_converted;
    
    // Instantiate ace adjusters for player and dealer
    ace_score_adjuster player_ace_adj (
        .current_score(player_score),
        .new_card(card_value),
        .has_ace(player_has_ace),
        .ace_converted(player_ace_converted),
        .adjusted_score(player_adjusted_score),
        .new_has_ace(player_new_has_ace),
        .new_ace_converted(player_new_ace_converted)
    );
    
    ace_score_adjuster dealer_ace_adj (
        .current_score(dealer_score),
        .new_card(card_value),
        .has_ace(dealer_has_ace),
        .ace_converted(dealer_ace_converted),
        .adjusted_score(dealer_adjusted_score),
        .new_has_ace(dealer_new_has_ace),
        .new_ace_converted(dealer_new_ace_converted)
    );

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
            player_ace_converted <= 1'b0;
            dealer_ace_converted <= 1'b0;
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
                        player_ace_converted <= 1'b0;
                        dealer_ace_converted <= 1'b0;
                        show_dealer_first <= 1'b0;
                        dealing_complete <= 1'b0;
                        player_busted <= 1'b0;
                    end
                end

                DEALING: begin
                    if (!dealing_complete) begin
                        case (cards_dealt)
                            3'd0: begin  // First player card
                                player_first_two <= player_adjusted_score;
                                player_score <= player_adjusted_score;
                                player_has_ace <= player_new_has_ace;
                                player_ace_converted <= player_new_ace_converted;
                                cards_dealt <= cards_dealt + 1'b1;
                            end
                            3'd1: begin  // First dealer card
                                dealer_first_two <= dealer_adjusted_score;
                                dealer_score <= dealer_adjusted_score;
                                dealer_has_ace <= dealer_new_has_ace;
                                dealer_ace_converted <= dealer_new_ace_converted;
                                cards_dealt <= cards_dealt + 1'b1;
                                show_dealer_first <= 1'b1;
                            end
                            3'd2: begin  // Second player card
                                player_first_two <= player_adjusted_score;
                                player_score <= player_adjusted_score;
                                player_has_ace <= player_new_has_ace;
                                player_ace_converted <= player_new_ace_converted;
                                cards_dealt <= cards_dealt + 1'b1;
                            end
                            3'd3: begin  // Second dealer card
                                dealer_first_two <= dealer_adjusted_score;
                                dealer_score <= dealer_adjusted_score;
                                dealer_has_ace <= dealer_new_has_ace;
                                dealer_ace_converted <= dealer_new_ace_converted;
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
                    if (hit_pressed && player_score < 21) begin  // Added score check
                        player_score <= player_adjusted_score;
                        player_has_ace <= player_new_has_ace;
                        player_ace_converted <= player_new_ace_converted;
                        
                        // Immediate bust check
                        if (player_adjusted_score > 21) begin
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
                            dealer_score <= dealer_adjusted_score;
                            dealer_has_ace <= dealer_new_has_ace;
                            dealer_ace_converted <= dealer_new_ace_converted;
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

//Ace score module
module ace_score_adjuster (
    input wire [4:0] current_score,
    input wire [3:0] new_card,
    input wire has_ace,
    input wire ace_converted,  // New input to track if ace was already converted
    output reg [4:0] adjusted_score,
    output reg new_has_ace,
    output reg new_ace_converted  // New output to track ace conversion
);
    always @(*) begin
        // Default: maintain current status
        new_has_ace = has_ace;
        new_ace_converted = ace_converted;
        adjusted_score = current_score;

        if (new_card == 4'd1) begin  // New card is Ace
            new_has_ace = 1'b1;
            // Only use 11 if it won't cause a bust
            if (current_score <= 10) begin
                adjusted_score = current_score + 11;
                new_ace_converted = 1'b0;  // New ace starts as 11
            end
            else begin
                adjusted_score = current_score + 1;
                new_ace_converted = 1'b1;  // New ace starts as 1
            end
        end
        else begin
            // Regular card
            adjusted_score = current_score + new_card;
            // Convert ace from 11 to 1 if needed and not already converted
            if (has_ace && !ace_converted && adjusted_score > 21) begin
                adjusted_score = adjusted_score - 10;
                new_ace_converted = 1'b1;
            end
        end
    end
endmodule