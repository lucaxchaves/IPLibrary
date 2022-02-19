`timescale 1 ns / 100 ps

module uart_tb;
    localparam CLOCK_PERIOD_NS = 100; // 10MHz clock signal
    localparam CLOCKS_PER_BIT = 87;
    localparam BIT_PERIOD_NS = CLOCKS_PER_BIT * CLOCK_PERIOD_NS;


    reg clk = 0;
    reg ext_clk = 0;
    reg rst = 1;

    reg enable_0 = 0;
    reg enable_1 = 0;
    
    reg [2:0] config_address_0 = 0;
    reg [2:0] config_address_1 = 0;
    
    reg config_write_enable_0 = 0;
    reg config_write_enable_1 = 0;
    
    reg [7:0] write_data_0 = 0;
    reg [7:0] write_data_1 = 0;

    wire [7:0] read_data_0;
    wire [7:0] read_data_1;

    wire tx0;
    wire rx0 = 1;
    wire tx1 = 1;




    wire rx_data_int_0;
    wire tx_done_int_0;
    wire rx_error_int_0;

    wire rx_data_int_1;
    wire tx_done_int_1;
    wire rx_error_int_1;

    uart uart_0(
        .clk(clk),
        .rst(rst),
        .enable(enable_0),
        .write_enable(config_write_enable_0),
        .address(config_address_0),
        .write_data(write_data_0),
        .read_data(read_data_0),
        .rx(rx0),
        .tx(tx0),
        .rx_data_int(rx_data_int_0),
        .tx_done_int(tx_done_int_0),
        .rx_error_int(rx_error_int_0)
   );

    uart uart_1(
        .clk(clk),
        .rst(rst),
        .enable(enable_1),
        .write_enable(config_write_enable_1),
        .address(config_address_1),
        .write_data(write_data_1),
        .read_data(read_data_1),
        .rx(tx0),
        .tx(tx1),
        .rx_data_int(rx_data_int_1),
        .tx_done_int(tx_done_int_1),
        .rx_error_int(rx_error_int_1)
   );

  

    always 
        #(CLOCK_PERIOD_NS/2) clk <= !clk;

    initial 
    begin
        $dumpfile("uart_tb.vcd");
        $dumpvars;

        rst = 0;
        #(CLOCK_PERIOD_NS*2);
        rst = 1;
        #(CLOCK_PERIOD_NS*2);


        // ---- UART 0 -----
    
        enable_0 = 1; // Enable UART 0
        enable_1 = 0; // Disable UART 1
 
        config_write_enable_0 = 1; //UART 0: WRITE
        config_write_enable_1 = 0; //UART 1: READ

        config_address_0 = 0;  //UART 0: CTRL
        write_data_0 = 8'b0_0_100_100; // Baud Rate: 115200 Bit Size: 8bits
        #(CLOCK_PERIOD_NS*2);

        config_address_0 = 1;  //UART 0: CTRL_INT
        write_data_0 = 8'b0_0_1_0_0_0_0_0; //Enable TX_DONE_INT 

        #(CLOCK_PERIOD_NS*2);

        config_address_0 = 2;  //UART 0: SEND
        write_data_0 = 8'hAB; //Save AB into SEND


        #(CLOCK_PERIOD_NS*2);
        // ---- UART 1 -----

        enable_0 = 0; // Disable UART 0
        enable_1 = 1; // Enable UART 1

        config_write_enable_0 = 0; //UART 0: READ
        config_write_enable_1 = 1; //UART 1: WRITE


        config_address_1 = 0;  //UART 1: CTRL
        write_data_1 = 8'b0_1_100_100; // Baud Rate: 115200 Bit Size: 8bits RX: Enabled

        #(CLOCK_PERIOD_NS*2);

        config_address_1 = 1;  //UART 1: CTRL_INT
        write_data_1 = 8'b1_1_0_0_0_0_0_0; //Enable RX_DONE_INT and RX_ERROR_INT 

        // ---- UART 0 and UART 1 -----

        #(CLOCK_PERIOD_NS*2);

        enable_0 = 1; // Enable UART 0
        enable_1 = 1; // Enable UART 1

        config_write_enable_0 = 1; //UART 0: WRITE
        config_write_enable_1 = 0; //UART 1: READ

        config_address_1 = 3;  //UART 1: RECEIVE
        
        config_address_0 = 0;  //UART 0: CTRL
        write_data_0 = 8'b1_0_100_100; // TX_START: 1

        #(BIT_PERIOD_NS*15);

        $finish;
    end




endmodule