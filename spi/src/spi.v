`timescale 1 ns / 100 ps

module spi (

    input wire clk,
    input wire rst,
    input wire enable,
    input wire write_enable,
    input wire [1:0] address,
    input wire [7:0] write_data,
    output wire [7:0] read_data,

    //SPI Protocol
    input sdi, 
    output sdo, 
    
    output wire cs_o, // Chip Select Out
    input wire cs_i, // Chip Select In
    input sclk_i,
    output sclk_o,

    //Interrupts
    output wire done_int);


    localparam SPI_MASTER = 0;
    localparam SPI_SLAVE = 1;
    
    //Clock Signals
    wire [2:0] prescaler_in;
    wire clock_polarity;
    wire clock_phase;
    
    //Control Signals
    wire spi_mode;
    wire process;

    //Status Signals
    wire w_ready;
    wire w_busy;
    wire w_done;

    //Interrupt
    wire done_int_en;
    assign done_int = done_int_en & w_done;

    //Send Buffer
    wire [7:0] send_data;
    
    //Received Buffer    
    wire [7:0] received_data;




    wire modified_clock;
    //Clock Generator
    spi_clock_generator i_spi_clock_generator(
        .clk(clk),
        .prescaler_in(prescaler_in),
        .spi_mode(spi_mode),
        .clk_out(modified_clock)
    );
    
    //SFR
    spi_register  i_spi_register(
        .clk(clk),
        .enable(enable),
        .rst(rst),
        .write_enable(write_enable),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .prescaler_in(prescaler_in),
        .clock_polarity(clock_polarity),
        .clock_phase(clock_phase),
        .process(process),
        .spi_mode(spi_mode),
        .send_data(send_data),
        .received_data(received_data),
        .done_int_en(done_int_en),
        .w_done(w_done),
        .w_busy(w_busy),
        .w_ready(w_ready)
    );

    wire spi_master_mode = spi_mode == 0;
    wire clock_in = spi_master_mode ? modified_clock : sclk_i;

    spi_module i_spi_module(
    //System Signals
    .clk(clk),
    .enable(enable),
    .rst(rst),

    //Control | Status Signals
    .spi_mode(spi_mode),
    .clock_phase(clock_phase),
    .clock_polarity(clock_polarity),

    .process(process),
    .done(w_done),
    .busy(w_busy),
    .ready(w_ready),

    //TX
    .tx_data(send_data),

    //RX
    .rx_data(received_data),

    //SPI Interface
    .sclk_o(sclk_o), //Serial Clock Out
    .sclk_i(clock_in), //Serial Clock In


    .cs_o(cs_o), // Chip Select Out
    .cs_i(cs_i), // Chip Select In

    .sdi(sdi), //Serial Data In
    .sdo(sdo) //Serial Data Out
);

    
    
endmodule