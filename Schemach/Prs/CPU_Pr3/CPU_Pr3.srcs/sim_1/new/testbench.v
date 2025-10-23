`timescale 1ns / 1ps
module testbench;

reg reset;
reg clk = 0;

always #5 clk = ~clk;

wire pc;

cpu unit(
    .clk(clk),
    .reset(reset),
    .pc(pc)
);
initial begin
    reset = 1;
    #100;
    reset = 0;
    #10000;
end
endmodule