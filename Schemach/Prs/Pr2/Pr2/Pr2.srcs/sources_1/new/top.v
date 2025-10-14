`timescale 1ns / 1ps

module top
#(DATA_SIZE = 8, STAGE_COUNT = 16)(
    input clk, reset, valid_in, fifo_out_ready,
    input [DATA_SIZE-1:0] data_in,
    output [DATA_SIZE-1:0] data_out,
    output valid_out
    );

dipeline #(
    .DATA_SIZE(DATA_SIZE), .STAGE_COUNT(STAGE_COUNT)
) dataflow (
    .clk(clk),
    .reset(reset),
    .fifo_out_ready(fifo_out_ready),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_stage_in(valid_stage),
    .data_out(data_out)
);

wire [STAGE_COUNT-1:0] valid_stage;

valid_chain #(.STAGE_COUNT(STAGE_COUNT))controlflow(
    .clk(clk),
    .reset(reset),
    .fifo_out_ready(fifo_out_ready),
    .valid_in(valid_in),
    // .data_out(data_out),
    .valid_out(valid_stage)
);

assign valid_out = valid_stage[STAGE_COUNT - 1];

endmodule
