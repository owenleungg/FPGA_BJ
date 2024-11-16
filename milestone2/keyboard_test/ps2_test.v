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

    // Internal signals
    wire reset = ~KEY[0];  // Active-high reset (KEY is active-low)
    
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

    // State tracking
    reg led_state;         // Current state of LEDs (on/off)
    reg [1:0] key_state;   // State machine for key press handling
    
    // Key state machine states
    localparam IDLE = 2'b00;
    localparam PRESSED = 2'b01;
    localparam BREAK_CODE = 2'b10;
    
    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            LEDR <= 10'b0;
            led_state <= 1'b0;
            key_state <= IDLE;
        end
        else begin
            case (key_state)
                IDLE: begin
                    if (received_data_en && received_data == 8'h33) begin  // 'H' key make code
                        key_state <= PRESSED;
                    end
                end
                
                PRESSED: begin
                    if (received_data_en && received_data == 8'hF0) begin  // Break code prefix
                        key_state <= BREAK_CODE;
                    end
                end
                
                BREAK_CODE: begin
                    if (received_data_en && received_data == 8'h33) begin  // 'H' key break code
                        // Toggle LED state
                        led_state <= ~led_state;
                        // Update LEDs based on new state
                        LEDR <= {10{~led_state}};
                        key_state <= IDLE;
                    end
                end
                
                default: key_state <= IDLE;
            endcase
        end
    end

endmodule