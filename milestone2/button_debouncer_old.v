// Button debouncer module
module button_debouncer (
    input wire clk,
    input wire rst_n,
    input wire key_hit,
    input wire key_stand,
    input wire key_deal,
    output wire hit_pressed,
    output wire stand_pressed,
    output wire deal_pressed
);
    reg [19:0] hit_counter, stand_counter, deal_counter;
    reg hit_was_pressed, stand_was_pressed, deal_was_pressed;

    assign hit_pressed = (hit_counter == 20'hFFFFF) && !hit_was_pressed;
    assign stand_pressed = (stand_counter == 20'hFFFFF) && !stand_was_pressed;
    assign deal_pressed = (deal_counter == 20'hFFFFF) && !deal_was_pressed;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin // active high reset 
            hit_counter <= 20'd0;
            stand_counter <= 20'd0;
            deal_counter <= 20'd0;
            hit_was_pressed <= 1'b0;
            stand_was_pressed <= 1'b0;
            deal_was_pressed <= 1'b0;
        end
        else begin
            // Hit button debouncing
            if (!key_hit) begin
                hit_counter <= 20'd0;
                hit_was_pressed <= 1'b0;
            end
            else if (hit_counter != 20'hFFFFF)
                hit_counter <= hit_counter + 1'b1;
            else
                hit_was_pressed <= 1'b1;

            // Stand button debouncing
            if (!key_stand) begin
                stand_counter <= 20'd0;
                stand_was_pressed <= 1'b0;
            end
            else if (stand_counter != 20'hFFFFF)
                stand_counter <= stand_counter + 1'b1;
            else
                stand_was_pressed <= 1'b1;

            // Deal button debouncing
            if (!key_deal) begin
                deal_counter <= 20'd0;
                deal_was_pressed <= 1'b0;
            end
            else if (deal_counter != 20'hFFFFF)
                deal_counter <= deal_counter + 1'b1;
            else
                deal_was_pressed <= 1'b1;
        end
    end
endmodule
