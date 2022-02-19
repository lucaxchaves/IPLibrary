from myhdl import *
import os


"""
Constants
"""
INTERNAL_CLOCK = 0
EXTERNAL_CLOCK = 1

MODE_DOWN = 1
MODE_UP = 0



def timer(
    clk,
    ext_clk,
    enable,
    rst,
    config_address,
    config_write_enable,
    write_data,
    read_data,
    comparator_1_output,
    comparator_0_output
):

    counter_enabled = Signal(0)
    clock_valid = Signal(0)
    clock_selector = Signal(0)
    count_mode = Signal(0)
    modified_ext_clk = Signal(0)
    start = Signal(0)
    prescaler_in = Signal(modbv(0,0,8))

    cmp_1_value = Signal(modbv(0,0,256))
    cmp_0_value = Signal(modbv(0,0,256))
    count_max = Signal(modbv(0,0,256))
    count_min = Signal(modbv(0,0,256))
    count = Signal(modbv(0,0,256))

    int_1_en = Signal(0)
    int_0_en = Signal(0)
    cmp_1_match = Signal(0)
    cmp_0_match = Signal(0)
    
    @always_comb
    def async_block_hdl():
        counter_enabled.next = (clock_valid and start)

    input_inst = timer_input_controller(
        clk,
        ext_clk,
        enable,
        clock_selector,
        prescaler_in,
        modified_ext_clk,
        clock_valid
    )

    output_inst = timer_output_controller(
        count,
        cmp_1_value,
        cmp_0_value, 
        int_1_en,
        int_0_en,
        comparator_1_output,
        comparator_0_output
    )

    counter_inst = up_down_counter(
        clk,
        rst, 
        counter_enabled,
        count_mode,
        count_max,
        count_min,
        count
    )
    register_inst = timer_register(
        clk,
        rst,
        enable,
        config_write_enable,
        write_data,
        read_data,
        config_address,
        clock_selector,
        int_0_en,
        int_1_en,
        count_mode,
        start,
        cmp_1_match,
        cmp_0_match,
        prescaler_in,
        count,
        count_max,
        count_min,
        cmp_1_value,
        cmp_0_value
    )
    return input_inst, output_inst, register_inst, counter_inst, async_block_hdl

"""
timer_register.v
"""
def timer_register(
    clk,
    rst,
    enable,
    write_enable,
    write_data,
    read_data,
    address,
    clock_selector,
    cmp_0_int_en,
    cmp_1_int_en,
    count_mode,
    start,
    cmp_1_f,
    cmp_0_f,
    prescaler_in,
    count,
    count_max,
    count_min,
    cmp_1_value,
    cmp_0_value
):
    """CONSTANTS"""
    CTRL_REGISTER_ADDR = 0
    STATUS_REGISTER_ADDR = 1
    COUNT_REGISTER_ADDR = 2
    CMP_1_REGISTER_ADDR = 3
    CMP_0_REGISTER_ADDR = 4
    COUNT_MIN_REGISTER_ADDR = 5
    COUNT_MAX_REGISTER_ADDR = 6
    
    """WIRES"""
    ctrl_register_selected = Signal(0)
    status_register_selected = Signal(0)
    cmp_1_register_selected = Signal(0)
    cmp_0_register_selected = Signal(0)
    count_register_selected = Signal(0)
    count_min_register_selected = Signal(0)
    count_max_register_selected = Signal(0)
    read_data_out = Signal(modbv(0,0,8))
    read_enabled = Signal(0) 
    write_enabled = Signal(0)
    clear_cmp_1_flag = Signal(0)
    clear_cmp_0_flag = Signal(0)
    cmp_1_flag_register = Signal(0)
    cmp_0_flag_register = Signal(0)
    
    @always_comb
    def signals():
        read_enabled.next = not write_enable and  enable; 
        write_enabled.next = write_enable and enable
        ctrl_register_selected.next = (address == CTRL_REGISTER_ADDR)
        status_register_selected.next = (address == STATUS_REGISTER_ADDR)
        cmp_1_register_selected.next = (address == CMP_1_REGISTER_ADDR)
        cmp_0_register_selected.next = (address == CMP_0_REGISTER_ADDR)
        count_register_selected.next = (address == COUNT_REGISTER_ADDR)
        count_min_register_selected.next = (address == COUNT_MIN_REGISTER_ADDR)
        count_max_register_selected.next = (address == COUNT_MAX_REGISTER_ADDR)
    
    @always_comb
    def clear():
        clear_cmp_1_flag.next = status_register_selected and cmp_1_int_en and write_enabled and write_data[7]
        clear_cmp_0_flag.next = status_register_selected and cmp_0_int_en and write_enabled and write_data[6]

    @always(clk.posedge, rst.negedge)
    def ctrl_reg():
        if not rst:
            cmp_1_int_en.next = 0
            cmp_0_int_en.next = 0
            clock_selector.next = 0
            count_mode.next = 0
            start.next = 0
            prescaler_in.next = 0
        else:
            if ctrl_register_selected and write_enabled:
                cmp_1_int_en.next = write_data[7]
                cmp_0_int_en.next = write_data[6]
                clock_selector.next = write_data[5]
                count_mode.next = write_data[4]
                start.next = write_data[3]
                prescaler_in.next = int(write_data & 0b111)
                print("prescale: ", (write_data ))


    @always(clk.posedge, rst.negedge, cmp_0_f)
    def status_0_flag():
        if not rst:
            cmp_0_flag_register.next = 0
        else:
            if clear_cmp_0_flag:
                cmp_0_flag_register.next = 0
            else:
                cmp_0_flag_register.next = cmp_0_flag_register or cmp_0_f     
    
    @always(clk.posedge, rst.negedge, cmp_1_f)
    def status_1_flag():
        if not rst:
            cmp_1_flag_register.next = 0
        else:
            if clear_cmp_1_flag:
                cmp_1_flag_register.next = 0
            else:
                cmp_1_flag_register.next = cmp_1_flag_register or cmp_0_f     



    @always(clk.posedge, rst.negedge)
    def cmp_1_reg():
        if not rst:
            cmp_1_value.next = 0 
        else:
            if cmp_1_register_selected and write_enabled:
                cmp_1_value.next = write_data

    @always(clk.posedge, rst.negedge)
    def cmp_0_reg():
        if not rst:
            cmp_0_value.next = 0 
        else:
            if cmp_0_register_selected and write_enabled:
                cmp_0_value.next = write_data


    @always(clk.posedge, rst.negedge)
    def count_min_reg():
        if not rst:
            count_min.next = 0 
        else:
            if count_min_register_selected and write_enabled:
                count_min.next = write_data

    @always(clk.posedge, rst.negedge)
    def count_max_reg():
        if not rst:
            count_max.next = 0 
        else:
            if count_max_register_selected and write_enabled:
                count_max.next = write_data

    
    @always_comb
    def mux_read():
        if not read_enabled:
            read_data.next = 0
            return

        if ctrl_register_selected:
            read_data_out.next = ConcatSignal(
                cmp_1_int_en,
                cmp_0_int_en,
                clock_selector,
                count_mode,
                start,
                prescaler_in
            )
 
        if status_register_selected:
            read_data_out.next = ConcatSignal(
                cmp_1_f,
                cmp_0_f,
                *[Signal(0) for _ in range(6)]
            )
 
        if cmp_1_register_selected:
            read_data_out.next = cmp_1_value
 
        if cmp_0_register_selected:
            read_data_out.next = cmp_0_value
 
        if count_register_selected:
            read_data_out.next = count
 
        if count_min_register_selected:
            read_data_out.next = count_min
 
        if count_max_register_selected:
            read_data_out.next = count_max

    @always_comb
    def async_values():
        read_data.next = read_data_out
    
    return clear, ctrl_reg,async_values, cmp_1_reg, cmp_0_reg, count_max_reg, count_min_reg, status_0_flag, status_1_flag, mux_read, signals

"""
prescaler.v
"""
def prescaler(clk_in, scale, clk_out):
    count = Signal(modbv(0, 0, 8))

    @always(clk_in.posedge)
    def process():
        count.next = count + 1 if count < scale else 0
        clk_out.next = (count < (scale//2)) 

    return process


"""
timer_input_controller.v
"""
def timer_input_controller(
    clk,
    ext_clk,
    enable,
    clock_selector,
    prescaler_in,
    modified_ext_clk,
    clock_valid
):
    modified_ext_clk = Signal(0)
    prescaler_inst = prescaler(ext_clk, prescaler_in, modified_ext_clk)

    @always_comb
    def comb():
        use_internal_clock = clock_selector == INTERNAL_CLOCK
        use_external_clock = clock_selector == EXTERNAL_CLOCK

        clock_valid.next = enable and ((use_internal_clock) or (use_external_clock and modified_ext_clk)) 

    return comb, prescaler_inst

"""
timer_output_controller.v
"""
def timer_output_controller(
    counter,
    cmp_1_value,
    cmp_0_value,
    int_1_en,
    int_0_en,
    cmp_1_match,
    cmp_0_match
):
    cmp_0_match = Signal(0)
    cmp_1_match = Signal(0)

    @always_comb
    def comb():
        counter_eq_1 = (counter == cmp_1_value)
        counter_eq_0 = (counter == cmp_0_value)

        cmp_1_match.next = int_1_en and counter_eq_1
        cmp_0_match.next = int_0_en and counter_eq_0

    return comb

"""
up_down_counter.v
"""
def up_down_counter(
    clk,
    rst,
    enable,
    count_mode,
    count_max,
    count_min,
    count
):

    @always(clk.posedge, rst.negedge)
    def seq():
        up_enabled = count_mode == MODE_UP
        down_enabled = count_mode == MODE_DOWN 
        if(not rst):
            count.next = count_max if down_enabled else count_min 
            return
        
        if not enable:
            return
        
        if up_enabled:    
            count.next = count + 1 if count < count_max else count_min 
        else:
            count.next = count - 1 if count > count_min else count_max 
    return seq

def clk_driver(clk, period=10):
    ''' Clock driver '''
    @always(delay(period//2))
    def driver():
        clk.next = not clk

    return driver

def checker(
    clk, 
    enable,
    rst,
    config_address,
    config_write_enable,
    write_data,
    py_read_data,
    py_comparator_1_output,
    py_comparator_0_output,
    v_read_data,
    v_comparator_1_output,
    v_comparator_0_output
):
    @always(clk.posedge)
    def check():
        cmp_1_match = py_comparator_1_output == v_comparator_1_output
        cmp_0_match = py_comparator_0_output == v_comparator_0_output
        read_data =  v_read_data == py_read_data

        # if not cmp_1_match or not cmp_0_match or not read_data:
        #     print("not match: cmp_1_match=", cmp_1_match, ' cmp_0_match=', cmp_0_match, ' read_data=', read_data)
        #     clk_n = now()
        #     print("clk=", clk_n, ' v_read_data=', v_read_data, ' py_read_data=',  py_read_data,' config_address=', config_address, '\n\n')

    return check

def verilog_timer(
        clk,
        ext_clk,
        enable,
        rst,
        config_address,
        config_write_enable,
        write_data,
        v_read_data,
        v_comparator_1_output,
        v_comparator_0_output
    ):
    ''' A Cosimulation object, used to simulate Verilog modules '''
    os.system('iverilog -o timer timer_top.v timer.v timer_register.v up_down_counter.v prescaler.v timer_output_controller.v timer_input_controller.v')
    return Cosimulation('vvp -m ./myhdl.vpi timer', 
        clk=clk, 
        ext_clk=ext_clk,
        enable=enable,
        rst=rst,
        config_address=config_address,
        config_write_enable=config_write_enable,
        write_data=write_data,
        read_data=v_read_data,
        comparator_1_output=v_comparator_1_output,
        comparator_0_output=v_comparator_0_output
    )
        

def bench():
    clk = Signal(0)
    ext_clk = Signal(0)
    enable = Signal(1)
    rst = Signal(1)
    config_address = Signal(modbv(0,0,8))
    config_write_enable = Signal(0)
    write_data = Signal(modbv(0,0,256))
    py_comparator_1_output = Signal(0)
    py_comparator_0_output = Signal(0)
    v_comparator_1_output = Signal(0)
    v_comparator_0_output = Signal(0)


    py_read_data = Signal(modbv(0,0,256))
    v_read_data = Signal(modbv(0,0,256))
    
    clk_driver_inst = clk_driver(clk)

    py_timer = timer(
        clk,
        ext_clk,
        enable,
        rst,
        config_address,
        config_write_enable,
        write_data,
        py_read_data,
        py_comparator_1_output,
        py_comparator_0_output
    )

    v_timer = verilog_timer(
        clk,
        ext_clk,
        enable,
        rst,
        config_address,
        config_write_enable,
        write_data,
        v_read_data,
        v_comparator_1_output,
        v_comparator_0_output
    )
    checker_inst = checker(
        clk, 
        enable,
        rst,
        config_address,
        config_write_enable,
        write_data,
        py_read_data,
        py_comparator_1_output,
        py_comparator_0_output,
        v_read_data,
        v_comparator_1_output,
        v_comparator_0_output
    )

    @instance   
    def check():
        yield clk.posedge
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        yield clk.posedge
        config_write_enable.next = 1
        config_address.next = 0
        write_data.next = 151#144 #b1_0_0_1_0_000
        yield clk.posedge
        yield clk.posedge
        config_address.next = 6
        write_data.next = 250 #b1_1_1_1_1_010
        yield clk.posedge
        yield clk.posedge
        config_address.next = 5
        write_data.next = 234 #b1_1_1_0_1_010
        yield clk.posedge
        yield clk.posedge
        config_address.next = 3
        write_data.next = 237 #b1_1_1_0_1_101
        yield clk.posedge
        yield clk.posedge
        config_address.next = 0
        write_data.next = 216 #b1_1_0_1_1_000

        yield clk.posedge
        yield clk.posedge
        config_write_enable.next = 0
        config_address.next = 2
        yield clk.posedge
        yield clk.posedge
        yield delay(240000)


        raise StopSimulation
    return instances()



if __name__ == "__main__":
    sim = Simulation(bench())
    sim.run()
        



