`timescale 1 ns / 100 ps

module prescaler #(
    parameter RESOLUTION_BITS=3
)(
 input clk_in,
 input enable,
 input [RESOLUTION_BITS-1:0] scale_sel,
 output reg clk_out);
 
    parameter SCALE_WIRE_VALUE = $clog2(1 << (2**RESOLUTION_BITS));
    
    reg [RESOLUTION_BITS-1:0] count = 0;
    
    wire [SCALE_WIRE_VALUE-1:0] scale = (1 << scale_sel);

    always @(posedge(clk_in)) 
    begin
        if(enable)
        begin
            count <= count + 1;
            if(count >= scale)
                count <= 0;
            
            clk_out <= (count < scale/2) ? 1 : 0;
        end
    end 

endmodule



