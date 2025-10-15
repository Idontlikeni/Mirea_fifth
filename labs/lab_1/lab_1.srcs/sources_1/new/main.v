`timescale 1ns / 1ps
module main(
    input clk, speed_up, speed_down, brightness_up, brightness_down,
    output reg error_output
);

reg [7:0] speed = 8'd128; // Speed of color change

// debouncers for 4 buttons
wire speed_up_signal, speed_up_signal_en;
wire speed_down_signal, speed_down_signal_en;
wire brightness_up_signal, brightness_up_signal_en;
wire brightness_down_signal, brightness_down_signal_up;

filtercon #(128) dbnc_spd_up(
    .clk(clk),
    .in_signal(speed_up),
    .clock_enable(1'b1),
    .out_signal(speed_up_signal),
    .out_signal_enable(speed_up_signal_en)
);

filtercon #(128) dbnc_spd_down(
    .clk(clk),
    .in_signal(speed_down),
    .clock_enable(1'b1),
    .out_signal(speed_down_signal),
    .out_signal_enable(speed_down_signal_en)
);

filtercon #(128) dbnc_brt_up(
    .clk(clk),
    .in_signal(brightness_up),
    .clock_enable(1'b1),
    .out_signal(brightness_up_signal),
    .out_signal_enable(brightness_up_signal_en)
);

filtercon #(128) dbnc_brt_down(
    .clk(clk),
    .in_signal(brightness_down),
    .clock_enable(1'b1),
    .out_signal(brightness_down_signal),
    .out_signal_enable(brightness_down_signal_up)
);

// clk_divider #(1024) div(
//     .clk(clk),
//     .clk_div(clk_div)
// );

// Sin gerenation via CORDIC
localparam pi = 3.14159265;

reg [63:0] i;
initial i = 0;

reg [31:0] cordic_angle; 
reg [31:0] cordic_angle_2;
reg [31:0] cordic_angle_3;
reg [9:0] trig_table_angle; 
wire [$clog2(360)-1:0] out;

counter#(.step(1), .mod(360)) cntr( // counter from 0 to 360 - angle;
    .clk(clk),
    .RE(1'b0),
    .CE(1'b1),
    .dir(1'b0),
    .out(out)
);

// always
// begin
//     //2^32 * a / 360 = 
//     trig_table_angle = ((1 << 10)*i)/360;
//     cordic_angle = ((1 << 32)*i)/360;
//     #10;
//     i = i + 1;
// end 

//Idea: implement clk divider for speed of color change;
assign cordic_angle = ((1 << 32)*out)/360; // to-do добавить еще 2 для сдвинутых sin.

reg [15:0] Xin, Yin;
wire [16:0] Xout, Yout, cos_cordic, sin_cordic;
initial 
begin
    Xin = 32000/1.647;
    Yin = 0;
end
//TO-DO: connect output from all CORDIC algos to the wires, then use them in PWM section.
CORDIC red (
    .clk(clk), 
    .angle(cordic_angle), 
    .Xin(Xin), 
    .Yin(Yin), 
    .COS_OUT(Xout), 
    .SIN_OUT(Yout)
);

CORDIC green (
    .clk(clk), 
    .angle(cordic_angle), 
    .Xin(Xin), 
    .Yin(Yin), 
    .COS_OUT(Xout), 
    .SIN_OUT(Yout)
);

CORDIC blue (
    .clk(clk), 
    .angle(cordic_angle), 
    .Xin(Xin), 
    .Yin(Yin), 
    .COS_OUT(Xout), 
    .SIN_OUT(Yout)
);

assign cos_cordic = Xout;
assign sin_cordic = Yout; // calculated sin via CORDIC


//-------------------------------PWM------------------------------------
wire pwm_out;

// Instantiate the pwm's for r,g,b, then make them dependent on CORDIC.
PWM_FSM #(.SIZE(4)) pwm_r (
    .clk(clk),
    .reset(1'b0),
    .clk_en(1'b1),
    .pwm_in(sin_cordic),
    .pwm_out(pwm_out)
);

PWM_FSM #(.SIZE(4)) pwm_g (
    .clk(clk),
    .reset(1'b0),
    .clk_en(1'b1),
    .pwm_in(sin_cordic),
    .pwm_out(pwm_out)
);

PWM_FSM #(.SIZE(4)) pwm_b (
    .clk(clk),
    .reset(1'b0),
    .clk_en(1'b1),
    .pwm_in(sin_cordic),
    .pwm_out(pwm_out)
);


endmodule