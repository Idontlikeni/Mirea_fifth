`timescale 1ns / 1ps

module CORDIC(
    input clk, [31:0] angle, [15:0] Xin, Yin,
    output [16:0] COS_OUT, SIN_OUT
    );

wire signed [31:0] atan_table [0:30];
`include "atan_table.vh"

reg signed [31:0] X [0:31];
reg signed [31:0] Y [0:31];
reg signed [31:0] RES_ACC [0:31];

wire [1:0] quadrant = angle[31:30]; 

always@(posedge clk)
    case (quadrant)
        2'b00, 2'b11: // 1-я и 4-я четверть круга
            begin
                X[0] <= Xin;
                Y[0] <= Yin;
                RES_ACC[0] <= angle;
            end
        2'b01: // 2-я четверть
            begin
                X[0] <= -Yin;
                Y[0] <= Xin;
                RES_ACC[0] <= {2'b00, angle[29:0]};
            end
        2'b10: // 3-я четверть
            begin
                X[0] <= Yin;
                Y[0] <= -Xin;
                RES_ACC[0] <= {2'b11, angle[29:0]};
            end
    endcase

genvar k;
generate
    for (k = 0; k < 31; k = k + 1)
    begin
        wire rotation_sign;
        wire signed [16:0] X_shift, Y_shift;
        
        assign X_shift = X[k] >>> k;
        assign Y_shift = Y[k] >>> k;
        assign rotation_sign = RES_ACC[k][31];
        
        always@(posedge clk)
        begin
            X[k+1] <= rotation_sign ? X[k] + Y_shift : X[k] - Y_shift;
            Y[k+1] <= rotation_sign ? Y[k] - X_shift : Y[k] + X_shift;
            RES_ACC[k+1] <= rotation_sign ? RES_ACC[k] + atan_table[k] : RES_ACC[k] - atan_table[k];
        end
    end
endgenerate 

assign COS_OUT = X[31];
assign SIN_OUT = Y[31];

endmodule
