`timescale 1ps/1ps

module timer_top();

    reg clk = 0;
    reg ext_clk = 0;
    reg rst = 1;
    reg enable = 1;
    reg [2:0] config_address = 0;
    reg config_write_enable = 0;
    reg [7:0] write_data = 0;
    wire comparator_1_output;
    wire comparator_0_output;
    wire [7:0] read_data;


    timer dut (
        clk,
        ext_clk,
        enable,
        rst, 
        config_address,
        config_write_enable,
        write_data,
        read_data,
        comparator_1_output,
        comparator_0_output);

    initial begin
    	$from_myhdl(clk, ext_clk, rst, enable,  config_address, config_write_enable, write_data);
    	$to_myhdl(comparator_1_output, comparator_0_output, read_data);
    end

    initial begin
        $dumpfile("timer_top.vcd");
        $dumpvars();
    end

endmodule