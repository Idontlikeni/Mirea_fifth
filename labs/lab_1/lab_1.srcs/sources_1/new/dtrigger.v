`timescale 1ns / 1ps
module dtrigger(
    input wire C,
    input wire D,
    input wire en,
    output reg q
);
    initial begin
        q<=0;
    end
    
    always @(posedge C) begin
        if(en) begin
            q <= D;
        end
    end
endmodule 
