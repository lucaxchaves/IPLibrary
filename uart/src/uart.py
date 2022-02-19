from mydhl import *



def baud_rate_generator(
    clk,
    enable_rx,
    baud_rate_sel,
    rx_clk,
    tx_clk
):
    
    size = 0

    rx_counter = Signal(modbv(0,0,size))
    tx_counter = Signal(modbv(0,0,size))
    rx_counter_max = Signal(modbv(0,0,size))
    tx_counter_max = Signal(modbv(0,0,size))

    tx_clk = Signal(0)
    rx_clk = Signal(0)

    @always_comb
    def async_logic():
        pass
    
    @always(clk.posedge)
    def rx_sync_logic():
        if()
    

    return 
        


def uart_register():
    pass


def uart_rx():
    pass
def uart_tx(
    clk,
    enable,
    rst,
    start,
    bit_count_sel,
    data_in,
    tx,
    done,
    busy
):
    state = Signal(0, )

    pass

def uart():
    pass