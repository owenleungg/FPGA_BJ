module currency_system (
    input wire CLOCK_50,
    input wire [3:0] KEY,          // KEY[0]=reset, KEY[1]=bet up, KEY[2]=bet down, KEY[3]=confirm bet
    input wire [7:0] SW,           // Optional: Use switches to set initial bankroll
    output wire [6:0] HEX4,        // Current bet amount
    output wire [6:0] HEX5,        
    input wire game_won,           // Input from FSM indicating win
    input wire game_push,          // Input from FSM indicating push (tie)
    input wire game_state_idle,    // Input from FSM indicating game is in IDLE state
    output wire [7:0] current_bet, // Output to FSM
    output wire bet_confirmed      // Output to FSM
);

    // Constants for bet amounts
    localparam INIT_BANKROLL = 8'd100;  // Start with $100
    localparam MIN_BET = 8'd5;          // Minimum bet $5
    localparam MAX_BET = 8'd50;         // Maximum bet $50
    localparam BET_INCREMENT = 8'd5;    // Increment bet by $5

    // Internal registers
    reg [7:0] bankroll;
    reg [7:0] bet_amount;
    reg bet_is_confirmed;
    reg [23:0] button_timer;       // For button debouncing

    // Addition/Subtraction module instance
    wire [7:0] add_result, sub_result;
    wire add_cout, sub_cout;

    adder_subtractor money_math (
        .A(bankroll),
        .B(bet_amount),
        .add_sub(1'b1),           // 1 for add, 0 for subtract
        .S_add(add_result),
        .S_sub(sub_result),
        .cout_add(add_cout),
        .cout_sub(sub_cout)
    );

    // Button debouncing and bet adjustment
    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin  // Reset
            bankroll <= INIT_BANKROLL;
            bet_amount <= MIN_BET;
            bet_is_confirmed <= 1'b0;
            button_timer <= 0;
        end
        else begin
            // Button timer
            if (button_timer > 0)
                button_timer <= button_timer - 1;

            // Only process bet changes when in IDLE state
            if (game_state_idle && button_timer == 0) begin
                if (!KEY[1] && bet_amount < MAX_BET && bet_amount < bankroll) begin  // Bet up
                    bet_amount <= bet_amount + BET_INCREMENT;
                    button_timer <= 24'd5000000;  // Debounce delay
                end
                else if (!KEY[2] && bet_amount > MIN_BET) begin  // Bet down
                    bet_amount <= bet_amount - BET_INCREMENT;
                    button_timer <= 24'd5000000;  // Debounce delay
                end
                else if (!KEY[3] && !bet_is_confirmed) begin  // Confirm bet
                    bet_is_confirmed <= 1'b1;
                    bankroll <= sub_result;  // Subtract bet from bankroll
                    button_timer <= 24'd5000000;  // Debounce delay
                end
            end

            // Handle game results
            if (!game_state_idle) begin
                bet_is_confirmed <= 1'b0;
                if (game_won)
                    bankroll <= add_result;  // Add winnings (2x bet)
                else if (game_push)
                    bankroll <= bankroll + bet_amount;  // Return bet amount
            end
        end
    end

    // Outputs
    assign current_bet = bet_amount;
    assign bet_confirmed = bet_is_confirmed;

    // Convert numbers to 7-segment display
    hex_display bet_display (
        .value(bet_amount),
        .hex5(HEX5),
        .hex4(hex4)
    );

endmodule

// Modified adder/subtractor module
module adder_subtractor (
    input [7:0] A,
    input [7:0] B,
    input add_sub,          // 1 for add, 0 for subtract
    output [7:0] S_add,     // Addition result
    output [7:0] S_sub,     // Subtraction result
    output cout_add,        // Addition carry
    output cout_sub         // Subtraction borrow
);

    wire [7:0] B_comp;      // B's complement for subtraction
    assign B_comp = ~B + 1; // Two's complement

    // Addition path
    full_adder8 adder (
        .A(A),
        .B(B),
        .cin(1'b0),
        .S(S_add),
        .cout(cout_add)
    );

    // Subtraction path
    full_adder8 subtractor (
        .A(A),
        .B(B_comp),
        .cin(1'b0),
        .S(S_sub),
        .cout(cout_sub)
    );

endmodule

// Seven-segment display decoder
module hex_display (
    input [7:0] value,
    output reg [6:0] hex5,  // Most significant digit
    output reg [6:0] hex4   // Least significant digit
);
    reg [3:0] digit1, digit0;

    always @(*) begin
        // Break value into decimal digits
        digit1 = value / 10;
        digit0 = value % 10;
        
        // Convert to 7-segment (active low)
        case(digit1)
            4'h0: hex5 = 7'b1000000;
            4'h1: hex5 = 7'b1111001;
            4'h2: hex5 = 7'b0100100;
            4'h3: hex5 = 7'b0110000;
            4'h4: hex5 = 7'b0011001;
            4'h5: hex5 = 7'b0010010;
            4'h6: hex5 = 7'b0000010;
            4'h7: hex5 = 7'b1111000;
            4'h8: hex5 = 7'b0000000;
            4'h9: hex5 = 7'b0010000;
            default: hex5 = 7'b1111111;
        endcase

        case(digit0)
            4'h0: hex4 = 7'b1000000;
            4'h1: hex4 = 7'b1111001;
            4'h2: hex4 = 7'b0100100;
            4'h3: hex4 = 7'b0110000;
            4'h4: hex4 = 7'b0011001;
            4'h5: hex4 = 7'b0010010;
            4'h6: hex4 = 7'b0000010;
            4'h7: hex4 = 7'b1111000;
            4'h8: hex4 = 7'b0000000;
            4'h9: hex4 = 7'b0010000;
            default: hex4 = 7'b1111111;
        endcase
    end
endmodule