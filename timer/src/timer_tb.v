`timescale 1 ns / 100 ps


module timer_tb();

    localparam  c_CLOCK_PERIOD_NS = 100; // 10MHz clock signal

    reg clk = 0;
    reg ext_clk = 0;
    reg rst = 1;
    reg enable = 1;
    reg [3:0] config_address = 0;
    reg config_write_enable = 0;
    reg [7:0] write_data = 0;
    wire comparator_1_output;
    wire comparator_0_output;
    wire [7:0] read_data;

    timer timer_0(
        .clk(clk),
        .ext_clk(ext_clk),
        .enable(enable),
        .rst(rst), 
        .config_address(config_address),
        .config_write_enable(config_write_enable),
        .write_data(write_data),
        .read_data(read_data),
        .comparator_1_output(comparator_1_output),
        .comparator_0_output(comparator_0_output)
    );

    always 
        #(c_CLOCK_PERIOD_NS/2) clk <= !clk;

    initial begin
        $dumpfile("timer_tb.vcd");
        $dumpvars;  
        rst = 0;
        #(c_CLOCK_PERIOD_NS*2);
        rst = 1;
        #(c_CLOCK_PERIOD_NS*2);

        config_write_enable = 1;
        config_address = 0;
        write_data = 8'b1_0_0_1_0_000;

        #(c_CLOCK_PERIOD_NS*2);

        config_write_enable = 1;
        config_address = 6;
        write_data = 8'hFA;

        #(c_CLOCK_PERIOD_NS*2);

        config_write_enable = 1;
        config_address = 5;
        write_data = 8'hEA;
        
        #(c_CLOCK_PERIOD_NS*2);

        config_write_enable = 1;
        config_address = 3;
        write_data = 8'hED;
        
        #(c_CLOCK_PERIOD_NS*2);


        config_write_enable = 1;
        config_address = 0;
        write_data = 8'b1_1_0_1_1_000;
        #c_CLOCK_PERIOD_NS;

        config_write_enable = 0;
        config_address = 2;

        #(c_CLOCK_PERIOD_NS*24000);

        config_write_enable = 1;
        config_address = 1;
        write_data = 8'b1_1_000000;

        #(c_CLOCK_PERIOD_NS);
        config_write_enable = 0;
        


        $finish;
    end




endmodule