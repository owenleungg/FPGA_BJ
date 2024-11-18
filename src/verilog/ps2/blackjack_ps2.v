module blackjack_ps2(
    inout PS2_CLK,
    inout PS2_DAT,
    input CLOCK_50,
    output reg hit_pressed,
    output reg stand_pressed,
    output reg deal_pressed,
);

    wire received_data_en, received_data;

    // Instantiate the PS/2 Controller
    PS2_Controller ps2_controller_inst (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(received_data),
        .received_data_en(received_data_en)
    );
    
    always @(posedge CLOCK_50) 
    begin
        case (received_data)
            8'h33: begin
                if (received_data_en && received_data == 8'h33) begin  // 'H' key make code
                    hit_pressed <= 1'b1;
                end
            end
                
            8'hF0: begin
                if (received_data_en && received_data == 8'hF0) begin  // Break code prefix
                    hit_pressed <= 1'b0;
                end
            end
                
            default: hit_pressed <= 1'b0;
        endcase
    end

    always @ (posedge CLOCK_50)
        begin
            LEDR[0] <= hit_pressed;
        end

endmodule