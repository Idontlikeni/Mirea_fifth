`timescale 1ns / 1ps

module PWM_testbench;

    reg clk;
    reg reset;
    reg clk_en;
    reg [3:0] pwm_in;
    wire pwm_out;

    // Instantiate the DUT (Device Under Test)
    PWM_FSM #(.SIZE(4)) dut (
        .clk(clk),
        .reset(reset),
        .clk_en(clk_en),
        .pwm_in(pwm_in),
        .pwm_out(pwm_out)
    );

    // Clock generation (100 MHz example, period=10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initial conditions
        reset = 1;
        clk_en = 1;
        pwm_in = 4'd0;

        #10;  // Hold reset for one clock cycle
        reset = 0;

        #100;  // Run with pwm_in=0 (0% duty)
        pwm_in = 4'd5;  // Set to ~31% duty (5/16)

        #200;  // Observe a few periods
        pwm_in = 4'd10;  // Set to ~62% duty (10/16)

        #200;
        pwm_in = 4'd15;  // Set to ~94% duty (15/16)

        #150;
        pwm_in = 4'd0;  // Back to 0%

        #150;
        $finish;  // End simulation
    end

endmodule