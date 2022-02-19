
`define IDLE       2'b00
`define START_BIT  2'b01 // transmitter only
`define DATA_BIT   2'b10
`define STOP_BIT   2'b11

`define BIT_COUNT_4 3'b000
`define BIT_COUNT_5 3'b001
`define BIT_COUNT_6 3'b010
`define BIT_COUNT_7 3'b011
`define BIT_COUNT_8 3'b100

`timescale 1 ns / 100 ps

module uart_tx (
    input  wire       clk,   
    input  wire       enable, 
    input  wire       rst, 
    input  wire       start,
    input  wire [2:0] bit_count_sel, 
    input  wire [7:0] in,    
    output reg        tx,   
    output reg        done,  
    output reg        busy
);
    
    reg [1:0] state  = `IDLE;
    reg [7:0] data   = 8'd0; 
    reg [3:0] bit_index  = 3'd0; 
    reg [3:0] index;
    reg [3:0] max_bit_index = 3'd0;
    
    always @(*)
    begin
        max_bit_index = bit_count_sel + 4; 
    end
    initial begin
        done <= 1'b0;
        tx <= 1'b1;
    end
    assign index = bit_index;

    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
        begin
            state <= `IDLE;
            tx <= 1'b1;
            done <= 1'b0;
            busy <= 1'b0;
        end   
        else
        begin
            case (state)
                default     : begin
                    state   <= `IDLE;
                end
                `IDLE       : begin
                    tx     <= 1'b1;
                    done    <= 1'b0;
                    busy    <= 1'b0;
                    bit_index  <= 0;
                    data    <= 0;
                    if (start & enable) begin
                        data    <= in; 
                        state   <= `START_BIT;
                    end
                end
                `START_BIT  : begin
                    tx     <= 1'b0; 
                    busy    <= 1'b1;
                    state   <= `DATA_BIT;
                    done    <= 1'b0;
                end
                `DATA_BIT  : begin 
                    tx     = data[index];
                    done    <= 1'b0;
                    if (bit_index == max_bit_index) begin
                        state   <= `STOP_BIT;
                    tx <= 1'b1;
                    end else begin
                        bit_index  <= bit_index + 1'b1;
                    end
                end
                `STOP_BIT   : begin 
                    bit_index  <= 3'd0;
                    tx <= 1'b1;
                    done    <= 1'b1;
                    data    <= 8'b0;
                    state   <= `IDLE;
                end
                default:
                    tx <= 0;
            endcase            
        end
    end

endmodule
