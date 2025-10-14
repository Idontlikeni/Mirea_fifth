`timescale 1ns / 1ps

module bubble #(STAGE_COUNT = 16)(
    input clk, reset, fifo_out_ready,
    input [STAGE_COUNT-1:0] valid_stage_in,
    output wire [STAGE_COUNT-1:0] is_ready
    );

assign is_ready[STAGE_COUNT - 1] = ~valid_stage_in[STAGE_COUNT - 1] || fifo_out_ready;

genvar i;

generate
    for(i = STAGE_COUNT - 2; i >= 0; i = i - 1)
    begin
        assign is_ready[i] = ~valid_stage_in[i] || is_ready[i+1];
    end
endgenerate

endmodule
