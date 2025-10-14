`timescale 1ns / 1ps

module valid_chain
# (STAGE_COUNT = 16)(
    input clk, reset, valid_in, fifo_out_ready,
    output reg [STAGE_COUNT-1:0] valid_out
    );

always@(posedge clk)
    if(reset)
        valid_out[0] <= 0;
    else if (fifo_out_ready)
        valid_out[0] <= valid_in;

genvar i;

generate
    for(i = 1; i < STAGE_COUNT; i = i + 1)
    begin
    always@(posedge clk)
        if(reset)
            valid_out[i] <= 0;
        else if (fifo_out_ready)
            valid_out[i] <= valid_out[i-1];
    end
endgenerate

endmodule
