`timescale 1 ns / 100 ps

module uart_rx #(
    parameter CLK_HZ = 10_000_000,
    parameter RX_CNT_WIDTH = $clog2((CLK_HZ / (115200)))+1
)(
    input clk,
    input enable,
    input rst, 
    input rx,
    input [RX_CNT_WIDTH-1:0] clks_per_bit,
    input  [2:0] bit_count_sel, 
    output data_valid,
    output [7:0] rx_data
);

    localparam  RX_IDLE = 2'b00;
    localparam  RX_START_BIT = 2'b01;
    localparam  RX_DATA_BITS = 2'b10;
    localparam  RX_STOP_BIT = 2'b11;
    reg r_rx_1 = 1'b1;
    reg r_rx = 1'b1;

    reg [7:0] clock_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] r_rx_data = 0;
    reg r_data_valid = 0;
    reg [1:0] state = 0;


    reg [3:0] max_bit_index = 3'd0;
    
    always @(*)
    begin
        max_bit_index = bit_count_sel + 3; 
    end

    always @(posedge clk)
    begin
      r_rx_1 <= rx;
      r_rx <= r_rx_1;
    end

    always @(posedge clk)
    begin
        case (state)
            RX_IDLE :
            begin
                r_data_valid <= 1'b0;
                clock_count <= 0;
                bit_index <= 0;
                if (r_rx == 1'b0) 
                    state<= RX_START_BIT;
                else
                    state <= RX_IDLE;
            end
            RX_START_BIT:
            begin
                if (clock_count == (clks_per_bit-1)/2)
                begin
                    if (r_rx == 1'b0)
                    begin
                        clock_count <= 0; 
                        state <= RX_DATA_BITS;
                    end
                    else
                        state <= RX_IDLE;
                end
                else
                begin
                    clock_count <= clock_count + 1;
                    state <= RX_START_BIT;
                end
            end 
            
            RX_DATA_BITS :
            begin
                if (clock_count < clks_per_bit-1)
                begin
                    clock_count <= clock_count + 1;
                    state <= RX_DATA_BITS;
                end
                else
                begin
                    clock_count <= 0;
                    r_rx_data[bit_index] <= r_rx;

                    if (bit_index < max_bit_index)
                    begin
                        bit_index <= bit_index + 1;
                        state <= RX_DATA_BITS;
                    end
                    else
                    begin
                        bit_index <= 0;
                        state <= RX_STOP_BIT;
                    end
                end
            end
            RX_STOP_BIT :
            begin
                if (clock_count < (clks_per_bit-1))
                begin
                    clock_count <= clock_count + 1;
                    state <= RX_STOP_BIT;
                end
                else
                begin
                    r_data_valid <= 1'b1;
                    clock_count <= 0;
                    state <= RX_IDLE;
                end
            end

            default :
                state <= RX_IDLE;
        endcase
    end

    assign data_valid = r_data_valid;
    assign rx_data = r_rx_data;

endmodule