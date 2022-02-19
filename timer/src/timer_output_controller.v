`timescale 1 ns / 100 ps
module timer_output_controller
#(
    parameter COUNTER_BIT_WIDTH = 8
)(
    input [COUNTER_BIT_WIDTH-1:0] counter,
    input [COUNTER_BIT_WIDTH-1:0] cmp_1_value,
    input [COUNTER_BIT_WIDTH-1:0] cmp_0_value,
    output wire cmp_1_match,
    output wire cmp_0_match
);

    assign cmp_1_match  = (counter == cmp_1_value);
    assign cmp_0_match  = (counter == cmp_0_value);
endmodule