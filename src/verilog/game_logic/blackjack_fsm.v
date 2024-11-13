module blackjack_fsm (
    input wire clk,
    input wire rst_n,
    input wire [4:0] player_score,    // Up to 21
    input wire [4:0] dealer_score,    // Up to 21
    input wire hit,                   // Player hit button
    input wire stand,                 // Player stand button
    input wire deal,                  // Start new game
    output reg dealing_cards,         // Signal to deal cards
    output reg player_active,         // Player's turn indicator
    output reg dealer_active,         // Dealer's turn indicator
    output reg game_finished         // Game over indicator
);

    // State encoding
    localparam IDLE = 3'b000;
    localparam DEALING = 3'b001;
    localparam PLAYER_TURN = 3'b010;
    localparam DEALER_TURN = 3'b011;
    localparam GAME_OVER = 3'b100;

    // State registers
    reg [2:0] current_state;
    reg [2:0] next_state;

    // State sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state combinational logic
    always @(*) begin
        // Default assignments
        next_state = current_state;
        dealing_cards = 1'b0;
        player_active = 1'b0;
        dealer_active = 1'b0;
        game_finished = 1'b0;

        case (current_state)
            IDLE: begin
                if (deal) begin
                    next_state = DEALING;
                end
            end

            DEALING: begin
                dealing_cards = 1'b1;
                // Check for initial blackjack
                if (player_score == 21 || dealer_score == 21) begin
                    next_state = GAME_OVER;
                end else begin
                    next_state = PLAYER_TURN;
                end
            end

            PLAYER_TURN: begin
                player_active = 1'b1;
                if (player_score == 21) begin
                    next_state = GAME_OVER;
                end
                else if (player_score > 21) begin
                    next_state = GAME_OVER;
                end
                else if (stand) begin
                    next_state = DEALER_TURN;
                end
                // Stay in PLAYER_TURN if hit button pressed and score < 21
            end

            DEALER_TURN: begin
                dealer_active = 1'b1;
                if (dealer_score >= 17) begin
                    next_state = GAME_OVER;
                end
                else if (dealer_score > 21) begin
                    next_state = GAME_OVER;
                end
                // Dealer continues hitting if score < 17
            end

            GAME_OVER: begin
                game_finished = 1'b1;
                if (deal) begin
                    next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end

endmodule