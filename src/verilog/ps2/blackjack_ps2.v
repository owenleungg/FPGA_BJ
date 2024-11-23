module blackjack_ps2 (
    input wire CLOCK_50,
    input wire reset,
    
    inout PS2_CLK,
    inout PS2_DAT,
    
    output reg hit_pressed,
    output reg stand_pressed,
    output reg deal_pressed,
    output wire [9:0] LEDR
);

    // Internal signals
    wire [7:0] ps2_key_data;
    wire ps2_key_pressed;
    reg [7:0] last_data_received;
    reg waiting_for_break;

    // PS2 scan codes
    localparam H_KEY = 8'h33;  // H key
    localparam S_KEY = 8'h1B;  // S key
    localparam D_KEY = 8'h23;  // D key
    localparam BREAK = 8'hF0;  // Break code

    // State tracking
    reg [1:0] key_state;
    localparam IDLE = 2'b00;
    localparam KEY_PRESSED = 2'b01;
    localparam WAIT_RELEASE = 2'b10;

    // Process key presses
    always @(posedge CLOCK_50) begin
        if (reset) begin
            hit_pressed <= 1'b0;
            stand_pressed <= 1'b0;
            deal_pressed <= 1'b0;
            waiting_for_break <= 1'b0;
            key_state <= IDLE;
            last_data_received <= 8'h00;
        end
        else if (ps2_key_pressed) begin
            case (key_state)
                IDLE: begin
                    if (ps2_key_data != BREAK) begin
                        last_data_received <= ps2_key_data;
                        case (ps2_key_data)
                            H_KEY: hit_pressed <= 1'b1;
                            S_KEY: stand_pressed <= 1'b1;
                            D_KEY: deal_pressed <= 1'b1;
                        endcase
                        key_state <= KEY_PRESSED;
                    end
                end
                
                KEY_PRESSED: begin
                    if (ps2_key_data == BREAK) begin
                        key_state <= WAIT_RELEASE;
                        hit_pressed <= 1'b0;
                        stand_pressed <= 1'b0;
                        deal_pressed <= 1'b0;
                    end
                end
                
                WAIT_RELEASE: begin
                    if (ps2_key_data == last_data_received) begin
                        key_state <= IDLE;
                    end
                end
                
                default: key_state <= IDLE;
            endcase
        end
        else begin
            if (key_state == KEY_PRESSED) begin
                hit_pressed <= 1'b0;
                stand_pressed <= 1'b0;
                deal_pressed <= 1'b0;
            end
        end
    end

    // Debug display
    assign LEDR = {key_state, waiting_for_break, last_data_received};

    // PS2 Controller instance
    PS2_Controller PS2 (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(ps2_key_data),
        .received_data_en(ps2_key_pressed)
    );

endmodule