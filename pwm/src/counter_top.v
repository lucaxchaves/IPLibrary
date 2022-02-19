
`timescale 1ps / 1ps
module counter_top;

reg clk = 0;
reg reset = 0;

wire [7:0] out;

counter dut (.clk(clk), .reset(reset), .out(out));

initial begin
	$from_myhdl(clk, reset);
	$to_myhdl(out);
end

initial begin
    $dumpfile("counter_top.vcd");
    $dumpvars();
end

endmodule