module ps2_test(
    inout PS2_CLK,
    inout PS2_DAT,
    input CLOCK_50,
    input [3:0] KEY,
    output [7:0] the_command,
    output send_command,
    output command_was_sent,
    output error_communication_timed_out,
    output [7:0] received_data,
    output received_data_en,
    output reg [9:0] LEDR
);

    // Assign default values to output signals we're not using
    assign the_command = 8'hFF;  // No command to send
    assign send_command = 1'b0;  // Not sending commands
    
    // Instantiate the PS/2 Controller
    PS2_Controller ps2_controller_inst (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .the_command(the_command),
        .send_command(send_command),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .command_was_sent(command_was_sent),
        .error_communication_timed_out(error_communication_timed_out),
        .received_data(received_data),
        .received_data_en(received_data_en)
    );
    
    reg hit_pressed, stand_pressed, deal_pressed;

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