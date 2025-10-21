`timescale 1ns / 1ps

module testbench;

// Inputs
reg clk;
reg rst;
reg speed_up;
reg speed_down;
reg brightness_up;
reg brightness_down;

// Outputs
wire error_output;
wire pwm_out;

// Testbench variables
integer i;
integer test_case;
integer pwm_high_count;
integer pwm_total_count;
real pwm_duty_cycle;

// Instantiate the Unit Under Test (UUT)
main uut (
    .clk(clk),
    .rst(rst),
    .speed_up(speed_up),
    .speed_down(speed_down),
    .brightness_up(brightness_up),
    .brightness_down(brightness_down),
    .error_output(error_output),
    .pwm_out(pwm_out)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock (10ns period)
end

// Main test sequence
initial begin
    $display("(1 << 32:  %b", (1<<32));
    // Initialize variables
    pwm_high_count = 0;
    pwm_total_count = 0;
    pwm_duty_cycle = 0.0;
    
    // Initialize inputs
    speed_up = 0;
    speed_down = 0;
    brightness_up = 0;
    brightness_down = 0;
    rst = 1;
    // Wait for initialization
    #100;
    
    rst = 0;
    $display("Starting Vivado simulation for main module");
    $display("Time(ns)\tTest Case\tDescription");
    $display("--------------------------------------------------");
    
    // Test Case 1: Normal operation - observe PWM output
    test_case = 1;
    $display("%0t\t%0d\t\tNormal operation - observing PWM", $time, test_case);
    #1000;
    
    // Test Case 2: Speed up button press
    test_case = 2;
    $display("%0t\t%0d\t\tSpeed up button press", $time, test_case);
    speed_up = 1;
    #1000; // Hold for 1us
    speed_up = 0;
    #2000;
    
    // Test Case 3: Speed down button press
    test_case = 3;
    $display("%0t\t%0d\t\tSpeed down button press", $time, test_case);
    speed_down = 1;
    #1000;
    speed_down = 0;
    #2000;
    
    // Test Case 4: Brightness up button press
    test_case = 4;
    $display("%0t\t%0d\t\tBrightness up button press", $time, test_case);
    brightness_up = 1;
    #1000;
    brightness_up = 0;
    #2000;
    
    // Test Case 5: Brightness down button press
    test_case = 5;
    $display("%0t\t%0d\t\tBrightness down button press", $time, test_case);
    brightness_down = 1;
    #1000;
    brightness_down = 0;
    #2000;
    
    // Test Case 6: Multiple button presses
    test_case = 6;
    $display("%0t\t%0d\t\tMultiple button presses", $time, test_case);
    repeat (5) begin
        speed_up = 1;
        #500;
        speed_up = 0;
        #500;
        brightness_up = 1;
        #500;
        brightness_up = 0;
        #500;
    end
    
    // Test Case 7: Long simulation to observe sine wave behavior
    test_case = 7;
    $display("%0t\t%0d\t\tLong run to observe CORDIC behavior", $time, test_case);
    #20000;
    
    // Test Case 8: Rapid button pressing
    test_case = 8;
    $display("%0t\t%0d\t\tRapid button pressing", $time, test_case);
    for (i = 0; i < 10; i = i + 1) begin
        speed_down = 1;
        brightness_down = 1;
        #100;
        speed_down = 0;
        brightness_down = 0;
        #100;
    end
    
    #10000;
    
    $display("");
    $display("All test cases completed successfully!");
    $display("Simulation finished at time %0t ns", $time);
    $finish;
end

// PWM duty cycle analysis
always @(posedge clk) begin
    pwm_total_count <= pwm_total_count + 1;
    if (pwm_out) begin
        pwm_high_count <= pwm_high_count + 1;
    end
    
    // Calculate and display duty cycle every 1000 cycles
    if (pwm_total_count >= 1000) begin
        pwm_duty_cycle = (real(pwm_high_count) / real(pwm_total_count)) * 100.0;
        $display("Time: %0t ns - PWM Duty Cycle: %0.2f%% (High: %0d, Total: %0d)", 
                 $time, pwm_duty_cycle, pwm_high_count, pwm_total_count);
        pwm_high_count = 0;
        pwm_total_count = 0;
    end
end

// Periodic status reporting
initial begin
    #5000;
    forever begin
        #5000; // Report every 5us
        $display("Time: %0t ns - Simulation running...", $time);
    end
end

endmodule