module blackjack_fsm (
    input wire CLOCK_50,           // 50MHz clock
    input wire [3:0] KEY,          // KEY[0]=hit, KEY[1]=stand, KEY[2]=reset
    output wire [4:0] player_score,    // Up to 21
    output wire [4:0] dealer_score,    // Up to 21
);

    // Internal signals
    wire [4:0] player_score;
    wire [4:0] dealer_score;
    wire [3:0] card_value;
    wire dealing_cards, player_active, dealer_active, game_finished;
    output reg current_card;

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
    
    // instantiate rng 
    rng u1(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .current_card(current_card)  // Output from rng used as card value
    );

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
                    if (~KEY[0] && player_score_reg < 21)
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
                if (~KEY[0] || ~KEY[1])
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
                else if (~KEY[1])
                    next_state = DEALER_TURN;
            end
            
            DEALER_TURN: begin
                if (dealer_score_reg >= 17 || dealer_score_reg >= 21)
                    next_state = GAME_OVER;
            end
            
            GAME_OVER: begin
                if (~KEY[0] && ~KEY[1])  // Both buttons to restart
                    next_state = IDLE;
            end
        endcase
    end
endmodule