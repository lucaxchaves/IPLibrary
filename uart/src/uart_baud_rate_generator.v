`timescale 1 ns / 100 ps

module uart_baud_rate_generator #(
    parameter CLK_HZ = 10_000_000,
    parameter RX_CNT_WIDTH = $clog2(CLKS_PER_BIT_RX_115200)+2
)(
    input wire clk,
    input [2:0] baud_rate_sel,
    output reg [RX_CNT_WIDTH-1: 0] clks_per_bit_rx,
    output reg tx_clk
);
    localparam CLKS_PER_BIT_RX_9600 = CLK_HZ / (9600);
    localparam MAX_RATE_TX_9600 = CLK_HZ / (2 * 9600);
    
    localparam CLKS_PER_BIT_RX_19200 = CLK_HZ / (19200);
    localparam MAX_RATE_TX_19200 = CLK_HZ / (2 * 19200);
    
    localparam CLKS_PER_BIT_RX_38400 = CLK_HZ / (38400);
    localparam MAX_RATE_TX_38400 = CLK_HZ / (2 * 38400);
    
    localparam CLKS_PER_BIT_RX_57600 = CLK_HZ / (57600);
    localparam MAX_RATE_TX_57600 = CLK_HZ / (2 * 57600);

    localparam CLKS_PER_BIT_RX_115200 = CLK_HZ / (115200);
    localparam MAX_RATE_TX_115200 = CLK_HZ / (2 * 115200);    
    
    localparam BAUD_9600 = 3'b000;
    localparam BAUD_19200 = 3'b001;
    localparam BAUD_38400 = 3'b010;
    localparam BAUD_57600 = 3'b011;
    localparam BAUD_115200 = 3'b100;

    localparam TX_CNT_WIDTH = $clog2(MAX_RATE_TX_115200)+1;

    reg [RX_CNT_WIDTH - 1:0] rx_counter = 0;
    reg [TX_CNT_WIDTH - 1:0] tx_counter = 0;
    reg [TX_CNT_WIDTH - 1:0] tx_max_counter;


    always @(baud_rate_sel) begin
        case(baud_rate_sel)
            BAUD_9600:
                tx_max_counter <= MAX_RATE_TX_9600;
            BAUD_19200:
                tx_max_counter <= MAX_RATE_TX_19200;
            BAUD_38400:
                tx_max_counter <= MAX_RATE_TX_38400;
            BAUD_57600:
                tx_max_counter <= MAX_RATE_TX_57600;
            BAUD_115200:
                tx_max_counter <= MAX_RATE_TX_115200;
        endcase
    end

    always @(baud_rate_sel) begin
        case(baud_rate_sel)
            BAUD_9600:
                clks_per_bit_rx <= CLKS_PER_BIT_RX_9600;
            BAUD_19200:
                clks_per_bit_rx <= CLKS_PER_BIT_RX_19200;
            BAUD_38400:
                clks_per_bit_rx <= CLKS_PER_BIT_RX_38400;
            BAUD_57600:
                clks_per_bit_rx <= CLKS_PER_BIT_RX_57600;
            BAUD_115200:
                clks_per_bit_rx <= CLKS_PER_BIT_RX_115200;
            default:
                clks_per_bit_rx <= CLKS_PER_BIT_RX_9600;
        endcase
    end

    initial begin
        tx_clk = 1'b0;
    end

    always @(posedge clk) begin
      if (tx_counter == (tx_max_counter - 1)) begin
              tx_counter <= 0;
              tx_clk <= ~tx_clk;
      end else begin
              tx_counter <= tx_counter + 1'b1;
      end
    end
endmodule
