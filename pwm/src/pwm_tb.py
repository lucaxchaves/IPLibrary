from cgitb import enable
from myhdl import *
import os

""" Counter """
def counter(clk, rst, out):

    @always(clk.posedge, rst.negedge)
    def driver():
        out.next = out + 1 if rst else 0
    
    return driver

""" PWM """
def pwm(clk, enable, pwm_in, out, counter_out):
    counter_rst = Signal(1)
    counter_inst = counter(clk, counter_rst, counter_out)

    @always_comb
    def driver():
        counter_rst.next = (enable)
        out.next = (pwm_in >= counter_out)
    
    return driver, counter_inst

""" Clock driver """
def clk_driver(clk, period=10):
    @always(delay(period//2))
    def driver():
        clk.next = not clk

    return driver


def verilog_pwm(clk, enable, pwm_in, out, counter_out):
    os.system('iverilog -o pwm pwm.v pwm_top.v')
    return Cosimulation('vvp -m ./myhdl.vpi pwm', clk=clk, enable=enable, pwm_in=pwm_in, out=out, counter_out=counter_out)




"""Compara a saída do modelo RTL feito em Verilog com o modelo funcional feito em Python """
def checker(clk, py_out, v_out, pwm_in,counter_out, v_counter_out):
    high_low = lambda value: 'HIGH' if value else 'LOW'
        
    @always(clk.posedge)
    def check():
        if(now() == 5): 
            return

        if(py_out!=v_out):
            print('error: time=', now(), '#', high_low(clk),  '\tout.py=', py_out, '\t out.v=', v_out, ' in=', pwm_in, ' counter_out=', counter_out, ' v_counter_out=', v_counter_out)

    return check


def bench():
    clk = Signal(bool(0))
    enable = Signal(bool(1))
    pwm_in = Signal(intbv(0, min = 0, max = 256))
    py_out = Signal(bool(0))
    counter_out = Signal(modbv(0, min = 0, max = 256))
    v_counter_out = Signal(modbv(0, min = 0, max = 256))
    v_out = Signal(0)

    clk_driver_inst = clk_driver(clk)
    py_pwm_inst = pwm(clk=clk, enable=enable, pwm_in=pwm_in, out=py_out, counter_out=counter_out)
    v_pwm_inst = verilog_pwm(clk=clk, enable=enable,pwm_in=pwm_in, out=v_out, counter_out=v_counter_out)
    checker_inst = checker(clk, py_out, v_out, pwm_in, counter_out, v_counter_out)

    @instance   
    def check():
        yield clk.posedge
        enable.next = 0
        yield clk.posedge
        enable.next = 1
        yield delay(512)
        pwm_in.next = 63
        yield delay(512)
        pwm_in.next = 127
        yield delay(512)
        pwm_in.next = 255
        yield delay(512)
        pwm_in.next = 0
        yield delay(512)


        raise StopSimulation
    return instances()

    


if __name__ == "__main__":
    sim = Simulation(bench())
    sim.run()