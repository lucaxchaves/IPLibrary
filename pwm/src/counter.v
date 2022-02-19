`timescale 1ps/1ps
module counter
#(parameter BIT_WIDTH = 8)
(
    input clk,
    input reset,
    output reg[BIT_WIDTH-1:0] out
);
    
    always @(posedge clk, negedge reset) begin
        if (!reset)
            out <= 1'b0;
        else
            out <= out + 1'b1;
    end

endmodule

