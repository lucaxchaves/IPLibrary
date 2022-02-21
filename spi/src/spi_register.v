`timescale 1 ns / 100 ps

module spi_register   (
    input clk,
    input enable,
    input rst,
    input write_enable,
    input [1:0] address,
    input [7:0]  write_data,
    output [7:0] read_data,
    output reg [2:0] prescaler_in,
    output reg clock_polarity,
    output reg clock_phase,
    output reg process,
    output reg spi_mode,
    output reg [7:0] send_data,
    input wire [7:0] received_data,
    output reg done_int_en,
    input wire w_done,
    input wire w_busy,
    input wire w_ready);

    localparam  CTRL_REGISTER_ADDR = 2'b00;
    localparam  SEND_REGISTER_ADDR = 2'b01;
    localparam  RECEIVE_REGISTER_ADDR = 2'b10;
    localparam  STATUS_REGISTER_ADDR = 2'b11;

    localparam  CTRL_REGISTER_RST = 8'd0;
    localparam  SEND_REGISTER_RST = 8'd0;
    localparam  RECEIVE_REGISTER_RST = 8'd0;
    localparam  STATUS_REGISTER_RST = 8'd0;

    wire ctrl_register_selected = (address == CTRL_REGISTER_ADDR);
    wire send_register_selected = (address == SEND_REGISTER_ADDR);
    wire receive_register_selected = (address == RECEIVE_REGISTER_ADDR);
    wire status_register_selected = (address == STATUS_REGISTER_ADDR);

    reg  [7:0] read_data_out = 0;

    wire read_enabled = !write_enable & enable; 
    wire write_enabled = write_enable & enable;
     
    //CTRL REG
    wire [7:0] ctrl_reg = {
        done_int_en,
        spi_mode,
        process,
        prescaler_in,
        clock_polarity,
        clock_phase
    };

    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            begin
                done_int_en <= CTRL_REGISTER_RST[7];
                spi_mode <= CTRL_REGISTER_RST[6];
                process <= CTRL_REGISTER_RST[5];
                prescaler_in <= CTRL_REGISTER_RST[4:2];
                clock_polarity <= CTRL_REGISTER_RST[1];
                clock_phase <= CTRL_REGISTER_RST[0];
            end
        else 
            begin
                if(ctrl_register_selected & write_enabled)  
                begin
                    done_int_en <= write_data[7];
                    spi_mode <= write_data[6];
                    process <= write_data[5];
                    prescaler_in <= write_data[4:2];
                    clock_polarity <= write_data[1];
                    clock_phase <= write_data[0];
                end
                // else
                //     process = 1'b0;

            end
    end

    //STATUS REG
    reg done =0;
    reg ready = 0;
    reg busy = 0;

    wire [7:0] status_reg = {
        done,
        ready,
        busy,
        5'd0
    };

    wire status_write_en = status_register_selected & write_enabled;

    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            begin
                done <= 0;
                ready <= 0; 
            end
        else 
            begin
                busy <= w_busy;
                ready <= w_ready;
                done <= status_write_en & write_data[7] ? 0 : (done | w_done);
            end
    end

    //SEND 
    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            send_data  <= SEND_REGISTER_RST; 
        else 
            if(send_register_selected & write_enabled)  
                send_data <= write_data;
    end


    //RECEIVE 
    reg [7:0] r_received_data;
    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            r_received_data <= SEND_REGISTER_RST; 
        else
            r_received_data <= w_done ? received_data : r_received_data;
    end

    //read data
    always @(*) begin
        case(address)
            CTRL_REGISTER_ADDR: read_data_out = ctrl_reg;
            STATUS_REGISTER_ADDR: read_data_out = status_reg;
            SEND_REGISTER_ADDR: read_data_out = send_data;
            RECEIVE_REGISTER_ADDR: read_data_out = r_received_data;
            default: read_data_out = 0;
        endcase
    end

    assign read_data = read_data_out & {8{read_enabled}};
endmodule
