

`timescale 1 ns / 100 ps
module timer
#(
    parameter COUNTER_BIT_WIDTH = 8
)(
    //Inputs
    input clk,
    input ext_clk,
    input enable,
    input rst, 
    input [3:0] config_address,
    input config_write_enable,
    input [COUNTER_BIT_WIDTH-1:0] write_data,

    //Outputs
    output [COUNTER_BIT_WIDTH-1:0] read_data,
    output comparator_1_output,
    output comparator_0_output);

    wire clock_selector;


    wire count_mode;
    wire cmp_0_int_en;
    wire cmp_1_int_en;
    wire start;

    wire [COUNTER_BIT_WIDTH-6:0] prescaler;
    wire [COUNTER_BIT_WIDTH-1:0] count;
    wire [COUNTER_BIT_WIDTH-1:0] cmp_1_value;
    wire [COUNTER_BIT_WIDTH-1:0] cmp_0_value;
    wire [COUNTER_BIT_WIDTH-1:0] count_max;
    wire [COUNTER_BIT_WIDTH-1:0] count_min;

    wire modified_ext_clk;
    wire clock_valid;
    wire cmp_0_match;
    wire cmp_1_match;


    //pre_scaler
    timer_input_controller input_ctrl 
    (
        .clk(clk),
        .ext_clk(ext_clk),
        .enable(enable),
        .clock_selector(clock_selector),
        .prescaler_in(prescaler),
        .modified_ext_clk(modified_ext_clk),
        .clock_valid(clock_valid)
    );
   

    //output controller
    timer_output_controller out_ctrl
    (
        .counter(count),
        .cmp_1_value(cmp_1_value),
        .cmp_0_value(cmp_0_value),
        .cmp_1_match(cmp_1_match),
        .cmp_0_match(cmp_0_match)
    ) ;


    //counter
    wire counter_enabled = (clock_valid & start);

    up_down_counter #(
        .COUNTER_BIT_WIDTH(COUNTER_BIT_WIDTH)
    ) counter_1 (
        .clk(clk),
        .rst(rst),
        .enable(counter_enabled),
        .count_mode(count_mode),
        .count_max(count_max),
        .count_min(count_min),
        .count(count)
    );



    //register file
    timer_register #(
        .COUNTER_BIT_WIDTH(COUNTER_BIT_WIDTH)
    ) register_file (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .write_enable(config_write_enable),
        .write_data(write_data),
        .read_data(read_data),
        .address(config_address),
        .clock_selector(clock_selector),
        .cmp_0_int_en(cmp_0_int_en),
        .cmp_1_int_en(cmp_1_int_en),
        .count_mode(count_mode),
        .start(start),
        .cmp_1_f(cmp_1_match),
        .cmp_0_f(cmp_0_match),
        .prescaler(prescaler),
        .count(count),
        .count_max(count_max),
        .count_min(count_min),
        .cmp_1_value(cmp_1_value),
        .cmp_0_value(cmp_0_value)
    );

    assign comparator_1_output = cmp_1_int_en & cmp_1_match;
    assign comparator_0_output = cmp_0_int_en & cmp_0_match;

endmodule