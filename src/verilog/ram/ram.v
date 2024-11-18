module blackjack_game_ram #(
    parameter CURRENCY_BITS = 16,
    parameter MAX_CARDS = 7
)(
    input wire clk,
    input wire rst,
    input wire [3:0] addr,
    input wire [CURRENCY_BITS-1:0] write_data,
    input wire write_en,
    output reg [CURRENCY_BITS-1:0] read_data
);

// Memory map
localparam
    ADDR_PLAYER_BALANCE = 4'h0,
    ADDR_CURRENT_BET = 4'h1,
    ADDR_PLAYER_CARD_COUNT = 4'h2,
    ADDR_DEALER_CARD_COUNT = 4'h3,
    ADDR_PLAYER_CARDS_START = 4'h4,
    ADDR_DEALER_CARDS_START = 4'h4 + MAX_CARDS;

// Memory array
reg [CURRENCY_BITS-1:0] ram [0:15];

// Write operation
always @(posedge clk) begin
    if (rst) begin
        // Initialize memory
        ram[ADDR_PLAYER_BALANCE] <= 1000;  // Starting balance
        ram[ADDR_CURRENT_BET] <= 0;
        ram[ADDR_PLAYER_CARD_COUNT] <= 0;
        ram[ADDR_DEALER_CARD_COUNT] <= 0;
        for (integer i = 0; i < MAX_CARDS; i = i + 1) begin
            ram[ADDR_PLAYER_CARDS_START + i] <= 0;
            ram[ADDR_DEALER_CARDS_START + i] <= 0;
        end
    end else if (write_en) begin
        ram[addr] <= write_data;
    end
end

// Read operation
always @(posedge clk) begin
    read_data <= ram[addr];
end

endmodule