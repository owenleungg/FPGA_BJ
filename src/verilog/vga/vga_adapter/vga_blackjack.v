module vga_blackjack (
    // Clock and Control
    input CLOCK_50,          
    input [0:0] KEY,
    
    // Game Control Signals
    input wire hit_pressed,    
    input wire deal_pressed,   
    //input wire dealer_turn,
    
    // Card Data
    input wire [3:0] card_value,
	 input wire deal_player_card_1,
    input wire [3:0] game_state,
    
    // VGA Outputs
    output [7:0] VGA_R,      
    output [7:0] VGA_G,      
    output [7:0] VGA_B,      
    output VGA_HS,           
    output VGA_VS,           
    output VGA_BLANK_N,      
    output VGA_SYNC_N,       
    output VGA_CLK,
    
    // Debug Output
    output wire [9:0] LEDR
);

    // VGA Drawing Coordinates
    wire [7:0] X;           
    wire [6:0] Y;           
    wire [3:0] XC;     
    wire [4:0] YC;
    wire Ex, Ey;
    wire [7:0] VGA_X;       
    wire [6:0] VGA_Y;       
    wire [2:0] VGA_COLOR;
    
    // Card Colors (from memory)
			// Diamonds
				wire [2:0] ace_of_diamonds_color, two_of_diamonds_color, three_of_diamonds_color,
           four_of_diamonds_color, five_of_diamonds_color, six_of_diamonds_color,
           seven_of_diamonds_color, eight_of_diamonds_color, nine_of_diamonds_color,
           ten_of_diamonds_color;

				// Clubs
				wire [2:0] ace_of_clubs_color, two_of_clubs_color, three_of_clubs_color,
           four_of_clubs_color, five_of_clubs_color, six_of_clubs_color,
           seven_of_clubs_color, eight_of_clubs_color, nine_of_clubs_color,
           ten_of_clubs_color;

				// Hearts
				wire [2:0] ace_of_hearts_color, two_of_hearts_color, three_of_hearts_color,
           four_of_hearts_color, five_of_hearts_color, six_of_hearts_color,
           seven_of_hearts_color, eight_of_hearts_color, nine_of_hearts_color,
           ten_of_hearts_color;
			  
			//spades
				wire [2:0] ace_of_spades_color, two_of_spades_color, three_of_spades_color,
               four_of_spades_color, five_of_spades_color, six_of_spades_color,
               seven_of_spades_color, eight_of_spades_color, nine_of_spades_color,
               ten_of_spades_color;
    reg [2:0] selected_color;
    
    // Card Position Tracking
    wire [7:0] card_x;
    wire [6:0] card_y;
    wire [2:0] player_card_count;
    wire [2:0] dealer_card_count;
	wire dealer_turn;
	assign dealer_turn = (game_state == 3'b011) ? 1 : 0;

    wire hit_pressed_512;
    // Extend drawing pulse
    pulse_extender_512 p1(
        .clk(CLOCK_50),
        .reset(deal_pressed),
        .pulse_in(hit_pressed || deal_player_card_1),
        .pulse_out(hit_pressed_512)
    );
	 
	 
    // Card value and suit latching
    wire [3:0] latched_card_value;
    wire [1:0] latched_suit;
    wire [1:0] suit;
	
	suit_rng suit_rng_inst(
		 .clk(CLOCK_50),
		 .rst_n(KEY[0]),             
		 .suit(suit)
	 );
	
    d_latch card_latch(
        .clk(CLOCK_50),
        .D(card_value),
        .en(hit_pressed || deal_player_card_1),
        .reset(~deal_pressed),
        .Q(latched_card_value)
    );
    
    d_latch suit_latch(
        .clk(CLOCK_50),
        .D(suit),
        .en(hit_pressed),
        .reset(~deal_pressed),
        .Q(latched_suit)
    );

    // Card positioning
    card_position_counter position_counter(
        .clk(CLOCK_50),
        .reset(deal_pressed),
        .dealer_turn(dealer_turn),
        .hit(hit_pressed),
        .game_state(game_state),        
        .player_card_count(player_card_count),
        .dealer_card_count(dealer_card_count),
        .card_x(card_x),
        .card_y(card_y)
    );

    // Drawing counters
    count U3 (CLOCK_50, ~deal_pressed, Ex, XC);    
        defparam U3.n = 4;
          
    regn U5 (1'b1, ~deal_pressed, hit_pressed_512, CLOCK_50, Ex);
        defparam U5.n = 1;
          
    count U4 (CLOCK_50, ~deal_pressed, Ey, YC);    
        defparam U4.n = 5;
          
    assign Ey = (XC == 4'b1111);

    // Position registers
    regn U7 (card_x + XC, ~deal_pressed, 1'b1, CLOCK_50, VGA_X);
        defparam U7.n = 8;
    regn U8 (card_y + YC, ~deal_pressed, 1'b1, CLOCK_50, VGA_Y);
        defparam U8.n = 7;

    // Card memory instances

	  
	 //diamonds
	  ace_of_diamonds_mem ({YC,XC}, CLOCK_50, ace_of_diamonds_color);
     two_of_diamonds_mem ({YC,XC}, CLOCK_50, two_of_diamonds_color);
     three_of_diamonds_mem ({YC,XC}, CLOCK_50, three_of_diamonds_color);
     four_of_diamonds_mem ({YC,XC}, CLOCK_50, four_of_diamonds_color);
     five_of_diamonds_mem ({YC,XC}, CLOCK_50, five_of_diamonds_color);
     six_of_diamonds_mem ({YC,XC}, CLOCK_50, six_of_diamonds_color);
     seven_of_diamonds_mem ({YC,XC}, CLOCK_50, seven_of_diamonds_color);
     eight_of_diamonds_mem ({YC,XC}, CLOCK_50, eight_of_diamonds_color);
     nine_of_diamonds_mem ({YC,XC}, CLOCK_50, nine_of_diamonds_color);
     ten_of_diamonds_mem ({YC,XC}, CLOCK_50, ten_of_diamonds_color);
	  
	 // clubs
	  ace_of_clubs_mem ({YC,XC}, CLOCK_50, ace_of_clubs_color);
     two_of_clubs_mem ({YC,XC}, CLOCK_50, two_of_clubs_color);
     three_of_clubs_mem ({YC,XC}, CLOCK_50, three_of_clubs_color);
     four_of_clubs_mem ({YC,XC}, CLOCK_50, four_of_clubs_color);
     five_of_clubs_mem ({YC,XC}, CLOCK_50, five_of_clubs_color);
     six_of_clubs_mem ({YC,XC}, CLOCK_50, six_of_clubs_color);
     seven_of_clubs_mem ({YC,XC}, CLOCK_50, seven_of_clubs_color);
     eight_of_clubs_mem ({YC,XC}, CLOCK_50, eight_of_clubs_color);
     nine_of_clubs_mem ({YC,XC}, CLOCK_50, nine_of_clubs_color);
     ten_of_clubs_mem ({YC,XC}, CLOCK_50, ten_of_clubs_color);
	  
	  //hearts
	  ace_of_hearts_mem ({YC,XC}, CLOCK_50, ace_of_hearts_color);
     two_of_hearts_mem ({YC,XC}, CLOCK_50, two_of_hearts_color);
     three_of_hearts_mem ({YC,XC}, CLOCK_50, three_of_hearts_color);
     four_of_hearts_mem ({YC,XC}, CLOCK_50, four_of_hearts_color);
     five_of_hearts_mem ({YC,XC}, CLOCK_50, five_of_hearts_color);
     six_of_hearts_mem ({YC,XC}, CLOCK_50, six_of_hearts_color);
     seven_of_hearts_mem ({YC,XC}, CLOCK_50, seven_of_hearts_color);
     eight_of_hearts_mem ({YC,XC}, CLOCK_50, eight_of_hearts_color);
     nine_of_hearts_mem ({YC,XC}, CLOCK_50, nine_of_hearts_color);
     ten_of_hearts_mem ({YC,XC}, CLOCK_50, ten_of_hearts_color);

	  
	 //spades
     ace_of_spades_mem ({YC,XC}, CLOCK_50, ace_of_spades_color);
     two_of_spades_mem ({YC,XC}, CLOCK_50, two_of_spades_color);
     three_of_spades_mem ({YC,XC}, CLOCK_50, three_of_spades_color);
     four_of_spades_mem ({YC,XC}, CLOCK_50, four_of_spades_color);
     five_of_spades_mem ({YC,XC}, CLOCK_50, five_of_spades_color);
     six_of_spades_mem ({YC,XC}, CLOCK_50, six_of_spades_color);
     seven_of_spades_mem ({YC,XC}, CLOCK_50, seven_of_spades_color);
     eight_of_spades_mem ({YC,XC}, CLOCK_50, eight_of_spades_color);
     nine_of_spades_mem ({YC,XC}, CLOCK_50, nine_of_spades_color);
     ten_of_spades_mem ({YC,XC}, CLOCK_50, ten_of_spades_color);

	 
	 
 // Card color selection
always @(*) begin
    case (latched_card_value)
        4'd1: case (latched_suit)
                    2'd0: selected_color = ace_of_diamonds_color;
                    2'd1: selected_color = ace_of_clubs_color;
                    2'd2: selected_color = ace_of_hearts_color;
                    2'd3: selected_color = ace_of_spades_color;
                endcase
        4'd2: case (latched_suit)
                    2'd0: selected_color = two_of_diamonds_color;
                    2'd1: selected_color = two_of_clubs_color;
                    2'd2: selected_color = two_of_hearts_color;
                    2'd3: selected_color = two_of_spades_color;
                endcase
        4'd3: case (latched_suit)
                    2'd0: selected_color = three_of_diamonds_color;
                    2'd1: selected_color = three_of_clubs_color;
                    2'd2: selected_color = three_of_hearts_color;
                    2'd3: selected_color = three_of_spades_color;
                endcase
        4'd4: case (latched_suit)
                    2'd0: selected_color = four_of_diamonds_color;
                    2'd1: selected_color = four_of_clubs_color;
                    2'd2: selected_color = four_of_hearts_color;
                    2'd3: selected_color = four_of_spades_color;
                endcase
        4'd5: case (latched_suit)
                    2'd0: selected_color = five_of_diamonds_color;
						  2'd1: selected_color = five_of_clubs_color;
                    2'd2: selected_color = five_of_hearts_color;
                    2'd3: selected_color = five_of_spades_color;
                endcase
        4'd6: case (latched_suit)
                    2'd0: selected_color = six_of_diamonds_color;
                    2'd1: selected_color = six_of_clubs_color;
                    2'd2: selected_color = six_of_hearts_color;
                    2'd3: selected_color = six_of_spades_color;
                endcase
        4'd7: case (latched_suit)
                    2'd0: selected_color = seven_of_diamonds_color;
                    2'd1: selected_color = seven_of_clubs_color;
                    2'd2: selected_color = seven_of_hearts_color;
                    2'd3: selected_color = seven_of_spades_color;
                endcase
        4'd8: case (latched_suit)
                    2'd0: selected_color = eight_of_diamonds_color;
                    2'd1: selected_color = eight_of_clubs_color;
                    2'd2: selected_color = eight_of_hearts_color;
                    2'd3: selected_color = eight_of_spades_color;
                endcase
        4'd9: case (latched_suit)
                    2'd0: selected_color = nine_of_diamonds_color;
                    2'd1: selected_color = nine_of_clubs_color;
                    2'd2: selected_color = nine_of_hearts_color;
                    2'd3: selected_color = nine_of_spades_color;
                endcase
        4'd10: case (latched_suit)
                    2'd0: selected_color = ten_of_diamonds_color;
                    2'd1: selected_color = ten_of_clubs_color;
                    2'd2: selected_color = ten_of_hearts_color;
                    2'd3: selected_color = ten_of_spades_color;
                endcase
        default: selected_color = 3'b000;
    endcase
end

    
    assign VGA_COLOR = selected_color;
	 
	 
    assign LEDR[3:0] = latched_card_value;
    assign LEDR[7:4] = game_state;
	 assign LEDR[9] = hit_pressed_512;

    // VGA Adapter
    vga_adapter VGA (
        .resetn(KEY[0]),   
        .clock(CLOCK_50),
        .colour(VGA_COLOR),
        .x(VGA_X),
        .y(VGA_Y),
        .plot(hit_pressed_512),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "blackjack_table.mif";

endmodule

module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (E)
            Q <= R;
endmodule

module count (Clock, Resetn, E, Q);
    parameter n = 8;
    input Clock, Resetn, E;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (E)
              Q <= Q + 1;
endmodule

module pulse_extender_512(
    input clk,
    input reset,
    input pulse_in,
    output reg pulse_out
);
    reg [8:0] counter;  // 9 bits for 512 cycles

    always @(posedge clk) begin
        if (reset) begin
            counter <= 9'd0;
            pulse_out <= 1'b0;
        end
        else if (pulse_in) begin
            counter <= 9'd0;
            pulse_out <= 1'b1;
        end
        else if (counter == 9'd511) begin
            pulse_out <= 1'b0;
        end
        else if (pulse_out) begin
            counter <= counter + 1'b1;
        end
    end
endmodule

module d_latch(
	input clk,
	input [3:0] D,
	input en,
	input reset,
	output reg [3:0] Q
);

always @ (posedge clk)
	if (!reset)
		Q <= 4'b0;
	else if (en)
		Q <= D;
endmodule

module card_position_counter(
    input clk,
    input reset,
    input hit,
    input dealer_turn,  
	 input [3:0] game_state,
	 output reg [2:0] player_card_count,
	 output reg [2:0] dealer_card_count,
    output reg [7:0] card_x,
    output reg [6:0] card_y
);
    // Start positions
    localparam PLAYER_INIT_X = 8'd24;
    localparam PLAYER_INIT_Y = 7'd80;  // Lower on screen for player
    localparam DEALER_INIT_X = 8'd24;
    localparam DEALER_INIT_Y = 7'd24;  // Higher on screen for dealer
    localparam X_OFFSET = 8'd20;
	 
	 localparam PLAYER_BUST = 4'b0100;  
    localparam DEALER_BUST = 4'b0101;  
    localparam PLAYER_TURN = 4'b0010; 
    localparam DEALER_TURN = 4'b0011; 


    always @(posedge clk) begin
        if (reset) begin
            player_card_count <= 3'd0;
            dealer_card_count <= 3'd0;
            card_x <= PLAYER_INIT_X;
            card_y <= PLAYER_INIT_Y;
        end
        else if (hit) begin
            if (dealer_turn && game_state != DEALER_BUST) begin
                if (dealer_card_count < 3'd5) begin
                    dealer_card_count <= dealer_card_count + 1'd1;
                    card_x <= DEALER_INIT_X + (dealer_card_count * X_OFFSET);
                    card_y <= DEALER_INIT_Y;
                end
            end
            else if (!dealer_turn && game_state == PLAYER_TURN && game_state != PLAYER_BUST) begin
                if (player_card_count < 3'd5) begin
                    player_card_count <= player_card_count + 1'd1;
                    card_x <= PLAYER_INIT_X + (player_card_count * X_OFFSET);
                    card_y <= PLAYER_INIT_Y;
                end
            end
        end
    end
endmodule
