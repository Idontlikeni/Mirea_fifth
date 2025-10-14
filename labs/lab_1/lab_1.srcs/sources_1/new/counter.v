`timescale 1ns / 1ps
module counter# (step = 1, mod = 16) (
    input clk,
    input dir,
    input RE, //Reset
    input CE, //Clock enable
    output reg [$clog2(mod)-1:0] out
);
    initial out  = 0;
    always@(posedge clk or posedge RE)
    begin
        if (RE)
            out <= 0; // Reset
        else if (CE) begin
            if (dir == 0)
                out <= (out + step) % mod;
            else
                out <= (mod + out - step) % mod;
        end
    end
endmodule
