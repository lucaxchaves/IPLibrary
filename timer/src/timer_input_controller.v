`timescale 1 ns / 100 ps
module timer_input_controller #(
    parameter PRESCALER_RESOLUTION_BITS=3
)(
    input clk,
    input ext_clk,
    input enable,
    input clock_selector,
    input [PRESCALER_RESOLUTION_BITS-1:0] prescaler_in, 
    output wire modified_ext_clk,
    output wire clock_valid
);

    localparam INTERNAL_CLOCK = 1'b0;
    localparam EXTERNAL_CLOCK = 1'b1;

    wire use_internal_clock = clock_selector == INTERNAL_CLOCK;    
    wire use_external_clock = clock_selector == EXTERNAL_CLOCK;

    prescaler prescaler_0(
        .clk_in(ext_clk),
        .scale_sel(prescaler_in),
        .clk_out(modified_ext_clk)
    );

    assign clock_valid = ((use_internal_clock & enable) 
        | (use_external_clock & enable & modified_ext_clk));

endmodule