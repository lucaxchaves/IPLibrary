`timescale 1 ns / 100 ps
module edge_detector(
    input clk,
    input signal,
    output negative_edge,
    output positive_edge);
    

    reg signal_delay;


    always @(posedge clk ) 
    begin
        signal_delay <= signal;
    end

    assign negative_edge = ~signal & signal_delay;
    assign positive_edge = signal & ~signal_delay;


endmodule