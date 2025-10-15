`timescale 1ns / 1ps
module PWM_FSM #(SIZE = 4)
(
    input clk, reset,
    input clk_en,
    input [SIZE-1:0] pwm_in,
    output reg pwm_out
);
reg [SIZE-1:0] pwm_reg, time_cnt;
initial
begin
    pwm_reg <= {SIZE{1'b0}};
    time_cnt <= {SIZE{1'b0}};
    pwm_out <= 1'b0;
end
always @ (posedge clk)
    
    if (reset)
    begin
        pwm_reg <= {SIZE{1'b0}};
        time_cnt <= {SIZE{1'b0}};
        pwm_out <= 1'b0;
    end
    else if (clk_en)
    begin

        if (time_cnt == {SIZE{1'b1}}-1)
        pwm_reg <= pwm_in;

        pwm_out <= (time_cnt < pwm_reg);
        time_cnt <= time_cnt + 1;
    end
endmodule