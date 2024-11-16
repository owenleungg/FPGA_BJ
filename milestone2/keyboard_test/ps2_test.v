module ps2_test(
    inout PS2_CLK,
    inout PS2_DAT,
    input CLOCK_50,
    input KEY,
    output [7:0] the_command,
    output send_command,
    output command_was_sent,
    output error_communication_timed_out,
    output [7:0] received_data,
    output received_data_en
    output [9:0] LEDR;
);

    // Instantiate the PS/2 Controller
    PS2_Controller ps2_controller_inst (
        .CLOCK_50(CLOCK_50),                          // System clock
        .reset(KEY[2]),                               // Reset from the reset button

        .the_command(the_command),                   // Command to send (if any)
        .send_command(send_command),                 // Send command signal

        .PS2_CLK(ps2_clk),                           // PS2 Clock line
        .PS2_DAT(ps2_dat),                           // PS2 Data line

        .command_was_sent(command_was_sent),         // Indicates command sent
        .error_communication_timed_out(error_communication_timed_out), // Error signal

        .received_data(received_data),               // Data received from PS2 device
        .received_data_en(received_data_en)          // New data flag
    );

    // Map received data to LEDs
    always @(posedge CLOCK_50 or posedge KEY[0]) begin
        if (KEY[0]) begin
            LEDR <= 10'b0;  // Reset LEDs
        end
        else if (received_data_en) begin
            LEDR[7:0] <= received_data;  // Display received data on LEDs
            LEDR[9:8] <= 2'b00;          // Unused LEDs
        end
    end
endmodule