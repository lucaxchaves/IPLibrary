`timescale 1 ns / 100 ps

module spi_tb;
    localparam CLOCK_PERIOD_NS = 100; // 10MHz clock signal

    reg clk = 0;
    reg rst = 1;

    reg enable_0 = 0;
    reg enable_1 = 0;
    
    reg [1:0] config_address_0 = 0;
    reg [1:0] config_address_1 = 0;
    
    reg config_write_enable_0 = 0;
    reg config_write_enable_1 = 0;
    
    reg [7:0] write_data_0 = 0;
    reg [7:0] write_data_1 = 0;

    wire [7:0] read_data_0;
    wire [7:0] read_data_1;


    wire sdi;
    wire sdo;
    wire sclk;

    wire cs;
    

    wire done_int_0;
    wire done_int_1;
    
    spi spi_0(
        .clk(clk),
        .rst(rst),
        .enable(enable_0),
        .write_enable(config_write_enable_0),
        .address(config_address_0),
        .write_data(write_data_0),
        .read_data(read_data_0),
        
        .sdi(sdi),
        .sdo(sdo),
        .cs_i(),
        .cs_o(cs),
        .sclk_i(),
        .sclk_o(sclk),

        .done_int(done_int_0)
   );

    spi spi_1(
        .clk(clk),
        .rst(rst),
        .enable(enable_1),
        .write_enable(config_write_enable_1),
        .address(config_address_1),
        .write_data(write_data_1),
        .read_data(read_data_1),
        
        .sdi(sdo),
        .sdo(sdi),
        
        .cs_o(),
        .cs_i(cs),
        .sclk_i(sclk),
        .sclk_o(),

        
        .done_int(done_int_1)
   );

  

    always 
        #(CLOCK_PERIOD_NS/2) clk <= !clk;

    initial 
    begin
        $dumpfile("spi_tb.vcd");
        $dumpvars;
        #(CLOCK_PERIOD_NS*2);
        rst = 0;
        #(CLOCK_PERIOD_NS*2);
        rst = 1;
        #(CLOCK_PERIOD_NS*2);
        // ---- SPI_MASTER -----
    
        enable_0 = 1; // Enable SPI Master
        config_write_enable_0 = 1;
        config_address_0 = 0; //CTRL Config
        write_data_0 = 8'b1_0_0_001_00; // Mode Master, all interrupts enabled, TX valid


        // ---- SPI_SLAVE -----
    
        enable_1 = 1; // Enable SPI Slave
        config_write_enable_1 = 1;
        config_address_1 = 0; //CTRL Config
        write_data_1 = 8'b1_1_0_000_00; // Mode Slave, all interrupts enabled, TX valid


        #(CLOCK_PERIOD_NS*2);

        // ---- SPI_MASTER -----
    
        enable_0 = 1; // Enable SPI Master
        config_write_enable_0 = 1;
        config_address_0 = 1; //SEND Config
        write_data_0 = 8'hFA; 

        // ---- SPI_SLAVE -----
    
        enable_1 = 1; // Enable SPI Slave
        config_write_enable_1 = 1;
        config_address_1 = 1; //SEND Config
        write_data_1 = 8'hAD; 

        #(CLOCK_PERIOD_NS*2);


        // ---- SPI_MASTER -----
    
        enable_0 = 1; // Enable SPI Master
        config_write_enable_0 = 1;
        config_address_0 = 0; //CTRL Config
        write_data_0 = 8'b1_0_1_001_00; // Mode Master, all interrupts enabled, TX valid


        // ---- SPI_SLAVE -----
    
        enable_1 = 1; // Enable SPI Slave
        config_write_enable_1 = 1;
        config_address_1 = 0; //CTRL Config
        write_data_1 = 8'b1_1_1_000_00; // Mode Slave, all interrupts enabled, TX valid


        #(CLOCK_PERIOD_NS*2);

       
        // ---- SPI_MASTER -----
    
        enable_0 = 1; // Enable SPI Master
        config_write_enable_0 = 0; // READ mode
        config_address_0 = 2; //RECEIVE register
        

        // ---- SPI_SLAVE -----
    
        enable_1 = 1; // Enable SPI Slave
        config_write_enable_1 = 0; // READ mode
        config_address_1 = 2; //RECEIVE register

        #(CLOCK_PERIOD_NS*1000);


        $finish;
    end


endmodule