`include "counter.v"
module pwm 
#(
    parameter RESOLUTION = 8
)(
    input clk,
    input enable, 
    input [RESOLUTION-1:0] in,
    output out);

    wire [RESOLUTION-1:0] counter_out;
    wire reset_counter;
    
    assign reset_counter = (enable == 1'b1);
    assign out =  (in >= counter_out); 
    
    counter #(
        .BIT_WIDTH(RESOLUTION)
    ) counter_1 
    (
        .clk(clk),
        .reset(reset_counter),
        .out(counter_out)
    );

    
endmodule