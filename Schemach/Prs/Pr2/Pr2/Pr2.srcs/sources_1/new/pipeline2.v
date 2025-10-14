`timescale 1ns / 1ps

module pipeline2 #(DATA_SIZE = 8, STAGE_COUNT = 16)(
    input clk, reset, valid_in, fifo_out_ready,
    input [STAGE_COUNT-1:0] valid_stage_in, // было
    input [STAGE_COUNT-1:0] is_ready,
    // input [STAGE_COUNT-1:0] is_ready, // добавлено
    input [DATA_SIZE-1:0] data_in,
    output [DATA_SIZE-1:0] data_out
    );

reg [DATA_SIZE - 1:0] pipeline_reg [0:STAGE_COUNT - 1];

always@(posedge clk)
    if (reset)
        pipeline_reg[0] <= 0;
    else if (is_ready[0]) // valid_in && fifo_out_ready
         pipeline_reg[0] <= data_in;

genvar i;
generate
    for(i = 1; i < STAGE_COUNT; i = i + 1)
    begin
        always@(posedge clk)
            if (reset)
                pipeline_reg[i] <= 0;
            else if (is_ready[i]) // было valid_stage_in[i-1] && fifo_out_ready
            //else if (is_ready[i - 1]) // стало
                 pipeline_reg[i] <= pipeline_reg[i-1] + 1;
    end
endgenerate

assign data_out = pipeline_reg[STAGE_COUNT - 1];

endmodule
