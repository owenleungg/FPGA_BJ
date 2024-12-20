//Demo on De1-Soc board that uses key0 to hit, key1 to stand, key2 to reset game
//displays player score on hex0-1
//displays dealer score on hex2-3
//displays state on hex 4-5

//CHANGES***
//note: no double or split logic, and dealer first card is not shown as it is displayed as 00
//displays letter A instead of 9?
//player and dealer no two initial cards
//there are ones and 11s but not both (ACE)
//No Push result when tie
//when player initial blackjack, dealer not given chance to tie game

module blackjack_game (
    input wire CLOCK_50,           // 50MHz clock
    input wire [3:0] KEY,          // KEY[0]=hit, KEY[1]=stand, KEY[2]=reset
    output wire [6:0] HEX0,        // Player score ones digit
    output wire [6:0] HEX1,        // Player score tens digit
    output wire [6:0] HEX2,        // Dealer score ones digit
    output wire [6:0] HEX3,        // Dealer score tens digit
    output wire [6:0] HEX4,        // Status display (P/d/b)
    output wire [6:0] HEX5         // Game state indicator
);

    // Internal signals
    wire [4:0] player_score;
    wire [4:0] dealer_score;
    wire [3:0] card_value;
    wire dealing_cards, player_active, dealer_active, game_finished;

    // LFSR for card generation
    reg [4:0] lfsr;
    wire feedback;
    reg [3:0] current_card;
    
    // Debouncing signals
    reg [19:0] hit_counter, stand_counter;
    reg hit_was_pressed, stand_was_pressed;
    wire hit_pressed, stand_pressed;

    // Game state signals
    reg [2:0] current_state;
    reg [2:0] next_state;
    reg [4:0] dealer_score_reg, player_score_reg;
    reg dealer_turn;

    // State definitions
    localparam IDLE = 3'b000;
    localparam DEALING = 3'b001;
    localparam PLAYER_TURN = 3'b010;
    localparam DEALER_TURN = 3'b011;
    localparam GAME_OVER = 3'b100;

    // LFSR feedback
    assign feedback = ~(lfsr[4] ^ lfsr[2]);

    // Debounced button presses
    assign hit_pressed = (hit_counter == 20'hFFFFF) && !hit_was_pressed;
    assign stand_pressed = (stand_counter == 20'hFFFFF) && !stand_was_pressed;

    // Score conversion for display
    wire [3:0] player_ones, player_tens;
    wire [3:0] dealer_ones, dealer_tens;
    
    assign player_ones = player_score_reg % 10;
    assign player_tens = player_score_reg / 10;
    assign dealer_ones = dealer_score_reg % 10;
    assign dealer_tens = dealer_score_reg / 10;

    // Debouncing logic
    always @(posedge CLOCK_50) begin
        // Hit button debouncing
        if (!KEY[0]) begin  // Active low buttons
            hit_counter <= 20'd0;
            hit_was_pressed <= 1'b0;
        end
        else if (hit_counter != 20'hFFFFF)
            hit_counter <= hit_counter + 1'b1;
        else
            hit_was_pressed <= 1'b1;

        // Stand button debouncing
        if (!KEY[1]) begin
            stand_counter <= 20'd0;
            stand_was_pressed <= 1'b0;
        end
        else if (stand_counter != 20'hFFFFF)
            stand_counter <= stand_counter + 1'b1;
        else
            stand_was_pressed <= 1'b1;
    end

    // Card generation logic
    always @(posedge CLOCK_50 or negedge KEY[2]) begin
        if (!KEY[2]) begin
            lfsr <= 5'b00010;
            current_card <= 4'd0;
        end
        else begin
            lfsr <= {lfsr[3:0], feedback};
            if (lfsr[3:0] < 4'd11)
                current_card <= lfsr[3:0] + 4'd1;
            else
                current_card <= 4'd10;  // Face cards = 10
        end
    end

    // Game state machine
    always @(posedge CLOCK_50 or negedge KEY[2]) begin
        if (!KEY[2]) begin
            current_state <= IDLE;
            player_score_reg <= 5'd0;
            dealer_score_reg <= 5'd0;
            dealer_turn <= 1'b0;
        end
        else begin
            current_state <= next_state;
            
            // Score updates
            case (current_state)
                DEALING: begin
                    if (!dealer_turn) begin
                        player_score_reg <= player_score_reg + current_card;
                        dealer_turn <= 1'b1;
                    end
                    else begin
                        dealer_score_reg <= dealer_score_reg + current_card;
                        dealer_turn <= 1'b0;
                    end
                end
                
                PLAYER_TURN: begin
                    if (hit_pressed && player_score_reg < 21)
                        player_score_reg <= player_score_reg + current_card;
                end
                
                DEALER_TURN: begin
                    if (dealer_score_reg < 17)
                        dealer_score_reg <= dealer_score_reg + current_card;
                end
            endcase
        end
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (hit_pressed || stand_pressed)
                    next_state = DEALING;
            end
            
            DEALING: begin
                if (player_score_reg >= 21 || dealer_score_reg >= 21)
                    next_state = GAME_OVER;
                else if (dealer_turn == 1'b0)
                    next_state = PLAYER_TURN;
            end
            
            PLAYER_TURN: begin
                if (player_score_reg >= 21)
                    next_state = GAME_OVER;
                else if (stand_pressed)
                    next_state = DEALER_TURN;
            end
            
            DEALER_TURN: begin
                if (dealer_score_reg >= 17 || dealer_score_reg >= 21)
                    next_state = GAME_OVER;
            end
            
            GAME_OVER: begin
                if (hit_pressed && stand_pressed)  // Both buttons to restart
                    next_state = IDLE;
            end
        endcase
    end

    // Seven segment display module instances
    char_7seg player_ones_display(player_ones, HEX0);
    char_7seg player_tens_display(player_tens, HEX1);
    char_7seg dealer_ones_display(dealer_ones, HEX2);
    char_7seg dealer_tens_display(dealer_tens, HEX3);
    
    // Status display on HEX4
    reg [6:0] status_display;
    always @(*) begin
        case (current_state)
            IDLE: status_display = 7'b1111111;      // Blank
            DEALING: status_display = 7'b0100001;   // d
            PLAYER_TURN: status_display = 7'b0001100; // P
            DEALER_TURN: status_display = 7'b0100001; // d
            GAME_OVER: begin
                if (player_score_reg > 21)
                    status_display = 7'b0000011;    // b (bust)
                else if (dealer_score_reg > 21 || 
                       (player_score_reg > dealer_score_reg && player_score_reg <= 21))
                    status_display = 7'b0001100;    // P (player wins)
                else
                    status_display = 7'b0100001;    // d (dealer wins)
            end
            default: status_display = 7'b1111111;   // Blank
        endcase
    end
    assign HEX4 = status_display;
    
    // Game state indicator on HEX5
    assign HEX5 = (current_state == IDLE) ? 7'b1111001 :     // 1
                  (current_state == DEALING) ? 7'b0100100 :   // 2
                  (current_state == PLAYER_TURN) ? 7'b0110000 : // 3
                  (current_state == DEALER_TURN) ? 7'b0011001 : // 4
                  7'b0010010;                                   // 5 (GAME_OVER)

endmodule

// Seven segment decoder module
module char_7seg(X, HEX);
	input [3:0] X;
	output [6:0] HEX;
    
	assign HEX[0] = (~X[3]&X[2]&~X[1]&~X[0])|(~X[3]&~X[2]&~X[1]&X[0])|(X[3]&X[2]&~X[1]&X[0])|(X[3]&~X[2]&X[1]&X[0]);
	assign HEX[1] = (X[3]&X[2]&~X[0])|(X[3]&X[1]&X[0])|(X[2]&X[1]&~X[0])|(~X[3]&X[2]&~X[1]&X[0]);
	assign HEX[2] = (X[3]&X[2]&~X[0])|(X[3]&X[2]&X[1])|(~X[3]&~X[2]&X[1]&~X[0]);
	assign HEX[3] = (~X[2]&~X[1]&X[0])|(X[2]&X[1]&X[0])|(~X[3]&X[2]&~X[1]&~X[0])|(X[3]&~X[2]&X[1]&~X[0]);
	assign HEX[4] = (~X[3]&X[0])|(~X[3]&X[2]&~X[1])|(~X[2]&~X[1]&X[0]);
	assign HEX[5] = (~X[3]&~X[2]&X[0])|(~X[3]&~X[2]&X[1])|(~X[3]&X[1]&X[0])|(X[3]&X[2]&~X[1]&X[0]);
	assign HEX[6] = (~X[3]&~X[2]&~X[1])|(X[3]&X[2]&~X[1]&~X[0])|(~X[3]&X[2]&X[1]&X[0]);
endmodule
