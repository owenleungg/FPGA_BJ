//Write to memory by setting write_en=1
//provide the addr_wr and data_in


module blackjack_ram (
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:0] addr_rd,
    input wire [ADDR_WIDTH-1:0] addr_wr,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire write_en,
    output reg [DATA_WIDTH-1:0] data_out
);

parameter ADDR_WIDTH = 5,    // 32 memory locations
parameter DATA_WIDTH = 8     // 8-bit data width

// Memory array definition
reg [DATA_WIDTH-1:0] ram [0:(2**ADDR_WIDTH)-1];

// Memory address mapping
localparam [ADDR_WIDTH-1:0]
    // Player cards (up to 11 cards max)
    ADDR_PLAYER_CARD_START = 5'h00,
    ADDR_PLAYER_CARD_COUNT = 5'h0B,
    
    // Dealer cards (up to 11 cards max)
    ADDR_DEALER_CARD_START = 5'h0C,
    ADDR_DEALER_CARD_COUNT = 5'h17,
    
    // Game state and currency
    ADDR_GAME_STATE = 5'h18,      // Current game state
    ADDR_CURRENT_BET = 5'h19,     // Current bet amount
    ADDR_PLAYER_BALANCE = 5'h1A,  // Player's total balance
    ADDR_PLAYER_SCORE = 5'h1B,    // Player's current hand score
    ADDR_DEALER_SCORE = 5'h1C;    // Dealer's current hand score

// Game state definitions
localparam [7:0]
    STATE_IDLE = 8'h00,
    STATE_BETTING = 8'h01,
    STATE_PLAYER_TURN = 8'h02,
    STATE_DEALER_TURN = 8'h03,
    STATE_GAME_OVER = 8'h04;

// Synchronous write operation
always @(posedge clk) begin
    if (rst) begin
        // Initialize memory on reset
        integer i;
        for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
            ram[i] <= 8'h00;
        end
        // Set initial game state
        ram[ADDR_GAME_STATE] <= STATE_IDLE;
        // Set initial player balance (e.g., 1000)
        ram[ADDR_PLAYER_BALANCE] <= 8'd100;  // Example starting balance
    end
    else if (write_en) begin
        ram[addr_wr] <= data_in;
    end
end

// Synchronous read operation
always @(posedge clk) begin
    data_out <= ram[addr_rd];
end

endmodule