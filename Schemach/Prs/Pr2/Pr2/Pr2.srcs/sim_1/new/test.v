`timescale 1ns / 1ps

module test;

reg clk = 0;
always #5 clk <= ~clk;

localparam DATA_SIZE = 8;
localparam STAGE_COUNT = 16;

reg reset, valid_in, fifo_out_ready;
// reg [DATA_SIZE-1:0] data_in;
wire [DATA_SIZE-1:0] data_out;
wire valid_out;

top #(.STAGE_COUNT(STAGE_COUNT), .DATA_SIZE(DATA_SIZE)) uut(
    .clk(clk),
    .reset(reset),
    .data_in(1),
    .fifo_out_ready(fifo_out_ready),
    .valid_in(valid_in),
    .data_out(data_out),
    .valid_out(valid_out)
);

initial
begin
    fifo_out_ready <= 1;
    valid_in <= 0;
    reset <= 1;
    @(posedge clk);
    @(posedge clk);
    reset <= 0;
    valid_in <= 1;
    
    @(posedge clk);
    @(posedge clk);
    valid_in <= 0;
    @(posedge clk);
    @(posedge clk);
    valid_in <= 1;
    @(posedge clk);
    @(posedge clk);
    fifo_out_ready <= 0;
    @(posedge clk);
    @(posedge clk);
    fifo_out_ready <= 1;
end
endmodule
