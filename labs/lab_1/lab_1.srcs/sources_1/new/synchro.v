`timescale 1ns / 1ps
module synchro(
    input in_signal,
    input clk,
    output q,
    output notq
);
    reg new_signal = 1'bx;
    reg last_signal = 1'bx;
    wire lq;
    dtrigger tr1(
        .C(clk),
        .D(new_signal),
        .en(1'b1),
        .q(lq)
    );
    dtrigger tr2(
        .C(clk),
        .D(last_signal),
        .en(1'b1),
        .q(q)
    );
    always @(posedge clk) begin
        new_signal=in_signal;
        last_signal=lq;
    end
endmodule
