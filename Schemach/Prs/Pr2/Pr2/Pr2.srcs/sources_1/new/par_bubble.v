`timescale 1ns / 1ps

module par_bubble #(STAGE_COUNT = 16)(
    input clk, reset, fifo_out_ready,
    input [STAGE_COUNT-1:0] valid_stage_in,
    output wire [STAGE_COUNT-1:0] is_ready
    );

assign is_ready[STAGE_COUNT - 1] = ~valid_stage_in[STAGE_COUNT - 1] || fifo_out_ready;

genvar i;
genvar j;
generate
    for(i = STAGE_COUNT - 2; i >= 0; i = i - 1)
    begin
        // assign is_ready[i] = ~valid_stage_in[i] || is_ready[i+1];

        for(j = i + 1; j < STAGE_COUNT; j = j + 1)
        begin
            assign is_ready[i] = ~valid_stage_in[i] || fifo_out_ready  || is_ready[j];
        end
    end
endgenerate

endmodule


//genvar i;
//// genvar j;
//generate
//    for(i = STAGE_COUNT - 2; i >= 0; i = i - 1)
//    begin
//        // assign is_ready[i] = ~valid_stage_in[i] || is_ready[i+1];
//        assign is_ready[i] = ~valid_stage_in[i] || fifo_out_ready  || |is_ready[STAGE_COUNT-1:i+1];
//    end
//endgenerate