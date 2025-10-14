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

assign cordic_angle = ((1 << 32)*out)/360; // to-do добавить еще 2 для сдвинутых sin.

reg [15:0] Xin, Yin;
wire [16:0] Xout, Yout, cos_cordic, sin_cordic;
initial 
begin
    Xin = 32000/1.647;
    Yin = 0;
end

CORDIC uut1 (
    .clk(clk), 
    .angle(cordic_angle), 
    .Xin(Xin), 
    .Yin(Yin), 
    .COS_OUT(Xout), 
    .SIN_OUT(Yout)
);
assign cos_cordic = Xout;
assign sin_cordic = Yout;


endmodule