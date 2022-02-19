`timescale 1 ns / 100 ps
module timer_register
#(
    parameter COUNTER_BIT_WIDTH = 8
)(
    input clk,
    input rst,
    input enable,
    input write_enable,
    input [COUNTER_BIT_WIDTH-1:0] write_data,
    output [COUNTER_BIT_WIDTH-1:0] read_data,
    input [3:0] address,

    output reg clock_selector,
    output reg cmp_0_int_en,
    output reg cmp_1_int_en,
    output reg count_mode,
    output reg start,
    input cmp_1_f,
    input cmp_0_f,
    output reg [COUNTER_BIT_WIDTH-6:0] prescaler,
    input wire [COUNTER_BIT_WIDTH-1:0] count,
    output reg  [COUNTER_BIT_WIDTH-1:0] count_max,
    output reg  [COUNTER_BIT_WIDTH-1:0] count_min,
    output reg[COUNTER_BIT_WIDTH-1:0] cmp_1_value,
    output reg[COUNTER_BIT_WIDTH-1:0] cmp_0_value
    
);
    localparam  CTRL_REGISTER_ADDR = 6'h0;
    localparam  STATUS_REGISTER_ADDR = 6'h1;
    localparam  COUNT_REGISTER_ADDR = 6'h2;
    localparam  CMP_1_REGISTER_ADDR = 6'h3;
    localparam  CMP_0_REGISTER_ADDR = 6'h4;
    localparam  COUNT_MIN_REGISTER_ADDR = 6'h5;
    localparam  COUNT_MAX_REGISTER_ADDR = 6'h6;

    localparam  CTRL_REGISTER_RST = 8'd0;
    localparam  STATUS_REGISTER_RST = 8'd0;
    localparam  CMP_1_REGISTER_RST = 8'd0;
    localparam  CMP_0_REGISTER_RST = 8'd0;
    localparam  COUNT_REGISTER_RST = 8'h0;
    localparam  COUNT_MIN_REGISTER_RST = 8'h0;
    localparam  COUNT_MAX_REGISTER_RST = 8'hFF;




    
    reg  [COUNTER_BIT_WIDTH-1:0] read_data_out = 0;


    wire ctrl_register_selected = (address == CTRL_REGISTER_ADDR);
    wire status_register_selected = (address == STATUS_REGISTER_ADDR);
    wire cmp_1_register_selected = (address == CMP_1_REGISTER_ADDR);
    wire cmp_0_register_selected = (address == CMP_0_REGISTER_ADDR);
    wire count_register_selected = (address == COUNT_REGISTER_ADDR);
    wire count_min_selected = (address == COUNT_MIN_REGISTER_ADDR);
    wire count_max_selected = (address == COUNT_MAX_REGISTER_ADDR);



    wire read_enabled = !write_enable & enable; 
    wire write_enabled = write_enable & enable;



    // CTRL register
    wire [COUNTER_BIT_WIDTH-1:0] ctrl_reg = {
        cmp_1_int_en,
        cmp_0_int_en,
        clock_selector,
        count_mode,
        start,
        prescaler
    };





    always @(posedge clk, negedge rst) 
    begin
        if(!rst)
        begin
            cmp_1_int_en = CTRL_REGISTER_RST[7];
            cmp_0_int_en = CTRL_REGISTER_RST[6];
            clock_selector = CTRL_REGISTER_RST[5];
            count_mode = CTRL_REGISTER_RST[4];
            start = CTRL_REGISTER_RST[3];
            prescaler = CTRL_REGISTER_RST[2:0];  
        end
        else
        begin 
            if(ctrl_register_selected & write_enabled)  
            begin
                cmp_1_int_en = write_data[7];
                cmp_0_int_en = write_data[6];
                clock_selector = write_data[5];
                count_mode = write_data[4];
                start = write_data[3];
                prescaler = write_data[2:0];  
            end
        end
    end

    // STATUS register
    wire clear_cmp_1_flag = status_register_selected & cmp_1_int_en & write_enabled & write_data[7];
    wire clear_cmp_0_flag = status_register_selected & cmp_0_int_en & write_enabled & write_data[6];

    reg cmp_1_flag_register = 0;
    reg cmp_0_flag_register = 0;

    wire [COUNTER_BIT_WIDTH-1:0] status_reg = {
        cmp_1_f,
        cmp_0_f,
        COUNTER_BIT_WIDTH-2'd0
    };

    always @(posedge clk, negedge rst, cmp_0_f) begin
        if(!rst)
        begin
            cmp_0_flag_register = 0;
        end
        else
        begin
            cmp_0_flag_register <= clear_cmp_0_flag ? 0 : cmp_0_flag_register |  cmp_0_f;
        end

    end

    always @(posedge clk, negedge rst, cmp_1_f) begin
        if(!rst)
        begin
            cmp_1_flag_register = 0;
        end
        else
        begin
            cmp_1_flag_register <= clear_cmp_1_flag ? 0 : cmp_1_flag_register |  cmp_1_f;
        end

    end

    // CMP_0 register
    always @(posedge clk, negedge rst) 
    begin
        if(!rst)
            cmp_0_value = CMP_0_REGISTER_RST;
        else 
            if(cmp_0_register_selected & write_enabled)  
                cmp_0_value = write_data;

    end
    // CMP_1 register
    always @(posedge clk, negedge rst) 
    begin
        if(!rst)
            cmp_1_value = CMP_1_REGISTER_RST;
        else   
            if(cmp_1_register_selected & write_enabled)  
                cmp_1_value = write_data;

    end
    // COUNT_MIN register
    always @(posedge clk, negedge rst) 
    begin
        if(!rst)
            count_min = COUNT_MIN_REGISTER_RST;
        else   
            if(count_min_selected & write_enabled)
                count_min = write_data;

    end

    // COUNT_MAX register
    always @(posedge clk, negedge rst) 
    begin
        if(!rst)
            count_max = COUNT_MAX_REGISTER_RST;
        else   
            if(count_max_selected & write_enabled)
                count_max = write_data;

    end


    //read data
    always @(*) begin
        case(address)
            CTRL_REGISTER_ADDR: read_data_out = ctrl_reg;
            STATUS_REGISTER_ADDR: read_data_out = status_reg;
            CMP_1_REGISTER_ADDR: read_data_out = cmp_1_value;
            CMP_0_REGISTER_ADDR: read_data_out = cmp_0_value;
            COUNT_REGISTER_ADDR: read_data_out = count;
            COUNT_MIN_REGISTER_ADDR: read_data_out = count_min;
            COUNT_MAX_REGISTER_ADDR: read_data_out = count_max;
            default: read_data_out = 0;
        endcase
    end

    assign read_data = read_data_out & {COUNTER_BIT_WIDTH{read_enabled}};

endmodule