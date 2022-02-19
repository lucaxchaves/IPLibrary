
`timescale 1ps/1ps
module pwm_top;

reg clk = 0;
reg enable = 1;

reg [7:0] pwm_in;
wire out;
wire [7:0] counter_out;

pwm dut (.clk(clk), .enable(enable), .in(pwm_in) ,.out(out));


assign counter_out = dut.counter_1.out;


initial begin
	$from_myhdl(clk, enable, pwm_in);
	$to_myhdl(out, counter_out);
end

initial begin
    $dumpfile("pwm_top.vcd");
    $dumpvars();
end

endmodule