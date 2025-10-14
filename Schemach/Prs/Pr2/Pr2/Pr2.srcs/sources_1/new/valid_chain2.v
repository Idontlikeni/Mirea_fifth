`timescale 1ns / 1ps

module valid_chain2
# (STAGE_COUNT = 16)(
    input clk, reset, valid_in, fifo_out_ready,
    input [STAGE_COUNT-1:0] is_ready,
    output reg [STAGE_COUNT-1:0] valid_out
    );

// reg [STAGE_COUNT-1:0] buffer;

always@(posedge clk)
    if(reset)
        valid_out[0] <= 0;
    else if (is_ready[0])
        valid_out[0] <= valid_in;

genvar i;

wire [STAGE_COUNT-1:0] allow;

generate
    for(i = 1; i < STAGE_COUNT; i = i + 1)
    begin
    always@(posedge clk)
        if(reset)
            valid_out[i] <= 0;
        else if (is_ready[i])
        begin
            valid_out[i] <= valid_out[i-1];
        end
    end
endgenerate

endmodule
