`timescale 1 ns / 100 ps

module uart #(
  parameter CLK_HZ = 10_000_000
)(
  input wire clk,
  input wire rst,
  input wire enable,
  input wire write_enable,
  input wire [2:0] address,
  
  input wire [7:0] write_data,
  output wire [7:0] read_data,

  //UART Protocol
  input wire rx,
  output wire tx,

  //Interrupts
  output wire rx_data_int,
  output wire tx_done_int,
  output wire rx_error_int);



  localparam  RX_CNT_WIDTH = $clog2(CLK_HZ / (115200)) +2;


  wire [RX_CNT_WIDTH-1: 0] clks_per_bit_rx;
  wire tx_clk;

  wire enable_rx, start_tx;

  wire [2:0] bit_count_sel;
  wire [2:0] baud_rate_sel;

  wire [7:0] send_data;
  wire [7:0] receive_data;

  wire w_data_sent;
  wire w_data_received;
  wire w_receive_failure;
  wire w_receive_busy;
  wire w_transmistter_busy;

  
  wire rx_error_int_en;
  wire rx_data_int_en;
  wire tx_done_int_en;


  uart_register i_uart_register(
    .clk(clk),
    .enable(enable),
    .rst(rst),
    .write_enable(write_enable),
    .address(address),
    .write_data(write_data),
    .read_data(read_data),
    .bit_count_sel(bit_count_sel),
    .baud_rate_sel(baud_rate_sel),
    .start_tx(start_tx),
    .enable_rx(enable_rx),
    .send_data(send_data),
    .receive_data(receive_data),
    .rx_error_int_en(rx_error_int_en),
    .rx_data_int_en(rx_data_int_en),
    .tx_done_int_en(tx_done_int_en),
    .w_data_sent(w_data_sent),
    .w_data_received(w_data_received),
    .w_receive_failure(w_receive_failure),
    .w_receive_busy(w_receive_busy),
    .w_transmistter_busy(w_transmistter_busy)
  );


  uart_baud_rate_generator #(
    .CLK_HZ(CLK_HZ),
    .RX_CNT_WIDTH(RX_CNT_WIDTH) 
  )
  i_uart_baud_rate_generator(
    .clk(clk),
    .baud_rate_sel(baud_rate_sel),
    .clks_per_bit_rx(clks_per_bit_rx),
    .tx_clk(tx_clk)
  );

  uart_tx i_uart_tx(
    .clk(tx_clk),
    .enable(enable),
    .rst(rst),
    .start(start_tx),
    .bit_count_sel(bit_count_sel),
    .in(send_data),
    .tx(tx),
    .done(w_data_sent),
    .busy(w_transmistter_busy)
  );

  uart_rx #(
    .CLK_HZ(CLK_HZ),
    .RX_CNT_WIDTH(RX_CNT_WIDTH)
  ) i_uart_rx (
    .clk(clk),
    .enable(enable),
    .rst(rst), 
    .rx(rx),
    .clks_per_bit(clks_per_bit_rx),
    .bit_count_sel(bit_count_sel), 
    .data_valid(w_data_received),
    .rx_data(receive_data)
  );

   
  //Interrupts
  assign rx_data_int = rx_data_int_en & w_data_received;
  assign tx_done_int = tx_done_int_en & w_data_sent;
  assign rx_error_int = rx_error_int_en & 0;

endmodule
