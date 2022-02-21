`timescale 1 ns / 100 ps

module spi_module(
    //System Signals
    input clk,
    input enable,
    input rst,

    //Control | Status Signals
    input wire spi_mode,
    input wire clock_phase,
    input wire clock_polarity,

    input process,
    output reg done,
    output busy,
    output ready,

    //TX
    input [7:0] tx_data,

    //RX
    output wire [7:0] rx_data,

    //SPI Interface
    output wire sclk_o, //Serial Clock Out
    input wire sclk_i, //Serial Clock In


    output wire cs_o, // Chip Select Out
    input wire cs_i, // Chip Select In

    input  wire sdi, //Serial Data In
    output wire sdo //Serial Data Out
);

    localparam SPI_MASTER_MODE = 0;
    localparam SPI_SLAVE_MODE = 1;

    wire master_mode_enabled = (spi_mode == SPI_MASTER_MODE);
    wire slave_mode_enabled = (spi_mode == SPI_SLAVE_MODE);



    reg activate_cs;
    reg activate_sclk;
    reg r_ready;

    reg status_ignore_first_edge;

	wire rising_sclk_edge;
	wire falling_sclk_edge;

    


    reg [7:0] tmp_rx_data;
    reg [7:0] bit_counter;

    wire delay_polarity = clock_phase ? ((clock_polarity ? rising_sclk_edge : falling_sclk_edge)) : ((clock_polarity ? sclk_i : !sclk_i));
	
    wire sample_edge = (clock_phase) ? ( (clock_polarity) ? (rising_sclk_edge) : (falling_sclk_edge) ) : ( (clock_polarity) ? (falling_sclk_edge) : (rising_sclk_edge) );

	wire shift_edge = (clock_phase) ? ( (clock_polarity) ? (falling_sclk_edge) : (rising_sclk_edge) ) : ( (clock_polarity) ? (rising_sclk_edge) : (falling_sclk_edge) );

    wire cs = master_mode_enabled ? cs_o : cs_i;



    assign sdo = activate_cs ? tx_data[bit_counter] :1'b0;


    edge_detector i_edge_detector(
        .clk(clk),
        .signal(sclk_i),
        .negative_edge(falling_sclk_edge),
        .positive_edge(rising_sclk_edge)
    );

    reg idle;

    always @(posedge clk or negedge rst) begin
        if(!rst)
        begin
                activate_cs <= 1'b0;
                activate_sclk <= 1'b0;
                bit_counter <= 7;
                status_ignore_first_edge <= 1'b0; 
                idle <= 1'b1;
                done <= 1'b0;
                r_ready <= 1;
        end
        else if(enable)
        begin
            if(idle)
                begin
                    done <= 1'b0;
                    if(process && delay_polarity)
                        begin
                            activate_cs <= 1'b1;
                            activate_sclk <= 1'b1;
                            idle <= 0;
                            status_ignore_first_edge <= 1'b0;    
                        end
                end
            else
                begin
                    done <= 1'b0;
                    if(!cs)
                    begin
                        if(sample_edge) 
                            tmp_rx_data[bit_counter] <= sdi;

                        if(shift_edge)
                        begin
                            if(clock_phase && !status_ignore_first_edge) 
                                status_ignore_first_edge <= 1'b1;
                            else
                            begin
                                if(bit_counter == 0)
                                begin
                                    activate_cs <= 1'b0;
                                    activate_sclk <= 1'b0;
                                    bit_counter <= 7;
                                    idle <= 0;
                                    done <= 1; 
                                end
                                else
                                    bit_counter <= bit_counter - 1;
                            end
                        end

                    end
                
                end
        end
    end

    
    assign sclk_o = master_mode_enabled ? (activate_sclk ? sclk_i : clock_polarity) : 1'b0;
    assign cs_o = master_mode_enabled ? (activate_cs ? 1'b0 : 1'b1) : 1'bz;

    assign rx_data = done ? tmp_rx_data : 0; 
	assign ready = r_ready;
    assign busy = !idle; 
endmodule