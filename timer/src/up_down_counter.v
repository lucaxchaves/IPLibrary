
`timescale 1 ns / 100 ps
module up_down_counter
#(
    parameter COUNTER_BIT_WIDTH = 8
)(
    input clk,
    input rst,
    input enable,
    input count_mode,
    input [COUNTER_BIT_WIDTH-1:0] count_max,
    input [COUNTER_BIT_WIDTH-1:0] count_min,
    output reg [COUNTER_BIT_WIDTH-1:0] count
);


    localparam MODE_DOWN = 1'b1;
    localparam MODE_UP = 1'b0;


    wire up = (count_mode == MODE_UP);
    wire down = (count_mode == MODE_DOWN);


    always @(posedge clk or negedge rst)
    begin
        if (!rst)
            count = down ? count_max : count_min;
        else
            begin
                if(enable)
                begin
                    if(up)
                    begin
                        if (count < count_max)
                            count = count + 1;
                        else
                            count = count_min;        
                    end
                    
                    else
                    begin 
                        if (count > count_min)
                            count = count - 1;
                        else
                            count = count_max;
                    end

                end
            end
    end
endmodule