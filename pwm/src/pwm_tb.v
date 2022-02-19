`timescale 1ps/1ps
`include "pwm.v"

module pwm_tb;
  reg clk = 0;
  reg enable = 1;
  reg [7:0] in = 8'd0;
  wire out;

  pwm pwm_1 (
    .clk(clk),
    .enable(enable),
    .in(in),
    .out(out)
  );
  always #1 clk = ~clk;  


  initial begin
    clk <= 0;
    in <= 0;
    $dumpfile("pwm_test.vcd");
    $dumpvars(0, pwm_1);
    #512
    in <= 8'd63;
    #512
    in <= 0;
    #512
    in <= 8'd127;
    #512
    in <= 0;
    #512
    in <= 8'd255;
    #512
    in <= 0;
    #512
    $finish;
  end

endmodule
