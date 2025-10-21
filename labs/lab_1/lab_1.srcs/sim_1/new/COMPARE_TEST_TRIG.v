`timescale 1ns / 1ps
module COMPARE_TEST_TRIG;

localparam pi = 3.14159265;
// Несинтезируемые функции расчётов синуса и косинуса по ряду Тейлора
// ------------------------------------------------------------------
//`include "tailor.v" 

//reg [63:0] real_sin_out, real_sin_res_bits;
//wire [10:0] real_sin_exp = real_sin_res_bits[62-:11];
//real real_sin_res, real_sin_i;
//initial
//begin
//    real_sin_i = 0;
//    while(1)
//    begin
//        real_sin_res = real_sin(real_sin_i);
//        real_sin_res_bits = $realtobits(real_sin_res);
//        real_sin_out = $rtoi(real_sin(real_sin_i) * 2.0**$signed(real_sin_exp - 1023 + 15));
//        #10; 
//        real_sin_i = real_sin_i + pi/180;
//    end    
//end

//reg [63:0] real_cos_out, real_cos_res_bits;
//wire [10:0] real_cos_exp = real_cos_res_bits[62-:11];
//real real_cos_res, real_cos_i;
//initial
//begin
//    real_cos_i = 0;
//    while(1)
//    begin
//        real_cos_res = real_cos(real_cos_i);
//        real_cos_res_bits = $realtobits(real_cos_res);
//        real_cos_out = $rtoi(real_cos(real_cos_i) * 2.0**$signed(real_cos_exp - 1023 + 15));
//        #10; 
//        real_cos_i = real_cos_i + pi/180;
//    end    
//end


// Генерация последовательности углов
// ----------------------------------
reg [63:0] i;
initial i = 0;

reg [31:0] cordic_angle; 
reg [9:0] trig_table_angle; 

always
begin
    //2^32 * a / 360 = 
    trig_table_angle = ((1 << 10)*i)/360;
    cordic_angle = ((1 << 32)*i)/360;
    #10;
    i = i + 1;
end 

// Синхросигнал
reg clk;
initial clk = 0;
always #5 clk <= ~clk;


  
// Модуль CORDIC
// -------------------


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

assign cos_cordic = (Xout[16] == 1'b1) ? ~Xout + 1 : Xout;
assign sin_cordic = (Yout[16] == 1'b1) ? ~Yout + 1 : Yout;

wire [16:0] cosz, sinz;

assign cosz = Xout + 17'd32768;
assign sinz = Yout + 17'd32768;
// Табличный модуль
// -------------------
//localparam TABLE_VALUE_WIDTH = 33;
//localparam TABLE_ANGLE_WIDTH = 10;

//wire [TABLE_VALUE_WIDTH-1:0] trig_table_sin;
//wire [TABLE_VALUE_WIDTH-1:0] trig_table_cos;

//trig_table #(
//    .VALUE_WIDTH(TABLE_VALUE_WIDTH),
//    .ANGLE_WIDTH(TABLE_ANGLE_WIDTH)
//) uut
//(
//    .angle_in(trig_table_angle),
//    .sin_out(trig_table_sin),
//    .cos_out(trig_table_cos)
//);


//// IP CORDIC

//wire ip_valid_out;
//wire [16:0] sin_ip_out, cos_ip_out;
//reg  [31:0] ip_cordic_angle;
//real r_ip_cordic_angle;
//initial
//begin
//    r_ip_cordic_angle = 0;
//    ip_cordic_angle = 0;
    
//    @(posedge clk)
    
//    while(1)
//    begin
//        @(posedge clk)
//        r_ip_cordic_angle = r_ip_cordic_angle + pi/180;
//        if (r_ip_cordic_angle > pi)
//            r_ip_cordic_angle = -pi;
//        ip_cordic_angle = $rtoi(r_ip_cordic_angle * (2.0**29));
        
//    end
    
//end

//cordic_0 u_ip (
//    .s_axis_phase_tdata(ip_cordic_angle),
//    .s_axis_phase_tvalid(1'b1),
//    .aclk(clk),
//    .m_axis_dout_tdata({sin_ip_out, cos_ip_out}),
//    .m_axis_dout_tvalid(ip_valid_out)
//);
endmodule
