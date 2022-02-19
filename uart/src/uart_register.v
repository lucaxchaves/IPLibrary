`timescale 1 ns / 100 ps
module uart_register   (
    input clk,
    input enable,
    input rst,
    input write_enable,
    input [2:0] address,
    input [7:0]  write_data,
    output [7:0] read_data,
    output reg [2:0] bit_count_sel,
    output reg [2:0] baud_rate_sel,
    output reg start_tx,
    output reg enable_rx,
    output reg [7:0] send_data,
    output wire [7:0] receive_data,
    output reg rx_error_int_en,
    output reg rx_data_int_en,
    output reg tx_done_int_en,
    output wire w_data_sent,
    output wire w_data_received,
    output wire w_receive_failure,
    output wire w_receive_busy,
    output wire w_transmistter_busy);

    localparam  CTRL_REGISTER_ADDR = 3'b000;
    localparam  CTRL_INT_REGISTER_ADDR = 3'b001;
    localparam  SEND_REGISTER_ADDR = 3'b010;
    localparam  RECEIVE_REGISTER_ADDR = 3'b011;
    localparam  STATUS_REGISTER_ADDR = 3'b100;

    localparam  CTRL_REGISTER_RST = 0;
    localparam  CTRL_INT_REGISTER_RST = 0;
    localparam  SEND_REGISTER_RST = 0;
    localparam  RECEIVE_REGISTER_RST = 0;
    localparam  STATUS_REGISTER_RST = 0;

    wire ctrl_register_selected = (address == CTRL_REGISTER_ADDR);
    wire ctrl_int_register_selected = (address == CTRL_INT_REGISTER_ADDR);
    wire send_register_selected = (address == SEND_REGISTER_ADDR);
    wire receive_register_selected = (address == RECEIVE_REGISTER_ADDR);
    wire status_register_selected = (address == STATUS_REGISTER_ADDR);

    reg  [7:0] read_data_out = 0;

    wire read_enabled = !write_enable & enable; 
    wire write_enabled = write_enable & enable;
     
    //CTRL REG
    wire [7:0] ctrl_reg = {
        start_tx,
        enable_rx,
        baud_rate_sel,
        bit_count_sel
    };

    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            begin
                bit_count_sel = CTRL_REGISTER_RST[2:0];
                baud_rate_sel = CTRL_REGISTER_RST[5:3];
                enable_rx = CTRL_REGISTER_RST[6];
                start_tx = CTRL_REGISTER_RST[7];
            end
        else 
            begin
                if(ctrl_register_selected & write_enabled)  
                begin
                    bit_count_sel = write_data[2:0];
                    baud_rate_sel = write_data[5:3];
                    enable_rx = write_data[6];
                    start_tx = write_data[7];
                end
            end
    end

    //CTRL_INT REG


    wire [7:0] ctrl_int_reg = {
        rx_error_int_en,
        rx_data_int_en,
        tx_done_int_en,
        5'd0
    };

    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            begin
                rx_error_int_en = CTRL_INT_REGISTER_RST[7];
                rx_data_int_en = CTRL_INT_REGISTER_RST[6];
                tx_done_int_en = CTRL_INT_REGISTER_RST[5];
            end
        else 
            begin
                if(ctrl_int_register_selected & write_enabled)  
                begin
                    rx_error_int_en = write_data[7];
                    rx_data_int_en = write_data[6];
                    tx_done_int_en = write_data[5];
                end
            end
    end

    //STATUS REG
    reg data_sent =0;
    reg data_received = 0;
    reg receive_failure = 0;
    reg receive_busy = 0;
    reg transmistter_busy = 0;
    
    

    wire [7:0] status_reg = {
        data_sent,
        data_received,
        receive_failure,
        receive_busy,
        transmistter_busy,
        3'd0
    };

    wire status_write_en = status_register_selected & write_enabled;

    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            begin
                data_sent = 0;
                data_received = 0;
                receive_failure = 0;
                receive_busy = 0;
                transmistter_busy = 0;
            end
        else 
            begin
                receive_busy = w_receive_busy;
                transmistter_busy = w_transmistter_busy;
                data_sent = status_write_en & write_data[0] ? 0 : (data_sent | w_data_sent);
                data_received = status_write_en & write_data[1] ? 0 : (data_received | w_data_received);
                receive_failure = status_write_en & write_data[2] ? 0 : (receive_failure | w_receive_failure);
            end
    end

    //SEND 
    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            send_data  = SEND_REGISTER_RST; 
        else 
            if(send_register_selected & write_enabled)  
                send_data = write_data;
    end


    //RECEIVE 
    reg r_receive_data;
    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
            r_receive_data = SEND_REGISTER_RST; 
        else
            r_receive_data = w_data_received ? receive_data : r_receive_data;
    end

    //read data
    always @(*) begin
        case(address)
            CTRL_REGISTER_ADDR: read_data_out = ctrl_reg;
            CTRL_INT_REGISTER_ADDR: read_data_out = ctrl_int_reg;
            STATUS_REGISTER_ADDR: read_data_out = status_reg;
            SEND_REGISTER_ADDR: read_data_out = send_data;
            RECEIVE_REGISTER_ADDR: read_data_out = r_receive_data;
            default: read_data_out = 0;
        endcase
    end

    assign read_data = read_data_out & {8{read_enabled}};
endmodule
