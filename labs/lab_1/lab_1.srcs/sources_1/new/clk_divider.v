`timescale 1ns / 1ps

module clk_divider#(CNTR_WDT = 8)(
    input clk,
    input rst,
    input [CNTR_WDT - 1:0] div,
    output reg clk_div
    );

reg [CNTR_WDT - 1:0] counter;
initial begin
    counter = {(CNTR_WDT){1'b0}};
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        counter <= 0;
        clk_div <= 0;
    end
    else begin
        counter = (counter + 1) % div;
        if(counter == 0)clk_div = 1'b1;
        else clk_div = 1'b0;
    end
end

endmodule
