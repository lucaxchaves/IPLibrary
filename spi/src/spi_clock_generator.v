`timescale 1 ns / 100 ps
module spi_clock_generator(
    input clk,
    input [2:0] prescaler_in,
    input spi_mode,
    output wire clk_out);

    localparam  SPI_MASTER = 1'b0;

    wire enable = spi_mode == SPI_MASTER;

    prescaler prescaler_0(
        .clk_in(clk),
        .enable(enable),
        .scale_sel(prescaler_in),
        .clk_out(clk_out)
    );

endmodule