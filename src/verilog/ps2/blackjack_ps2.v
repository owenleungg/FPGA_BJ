module blackjack_ps2(
    inout PS2_CLK,
    inout PS2_DAT,
    input CLOCK_50,
    output reg hit_pressed,
    output reg stand_pressed,
    output reg deal_pressed,
    output reg [9:0] LEDR,
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
            8'h33: begin // H key
                hit_pressed <= 1'b1;    
                LEDR[0] <= 1'b1;      
            end
  
            8'h1B: begin // S key
                stand_pressed <= 1'b1;   
                LEDR[1] <= 1'b1;       
            end
        
           8'h23: begin // D key
                stand_pressed <= 1'b1; 
                LEDR[2] <= 1'b1;         
            end
                
            8'hF0: begin // Break
                stand_pressed <= 1'b0;
            end
                
            default: hit_pressed <= 1'b0;
                    stand_pressed <= 1'b0;
                    deal_pressed <= 1'b0;
                    LEDR[0] <= 1'b0;
                    LEDR[1] <= 1'b0;
                    LEDR[2] <= 1'b0;
        endcase
    end

    always @ (posedge CLOCK_50)
        begin
            LEDR[0] <= hit_pressed;
        end

endmodule