CC = iverilog
FLAGS =-g2012 -Wall -Winfloop 

TOP_FILE=src/uart.v
TEST_BENCH_FILE=tb/uart_tb.v

OUTPUT_FILENAME=uart_tb.out
WAVE_FILENAME=uart_tb.vcd

INCLUDES=src/uart_baud_rate_generator.v src/uart_register.v src/uart_rx.v src/uart_tx.v 





compile: $(TOP_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(INCLUDES) $(TOP_FILE)


clean:
	rm -f $(WAVE_FILENAME) $(OUTPUT_FILENAME) 

vvp: $(TEST_BENCH_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(INCLUDES) $(TOP_FILE) $(TEST_BENCH_FILE) -s uart_tb
	
	vvp $(OUTPUT_FILENAME)


simulate: $(TEST_BENCH_FILE) clean vvp
	gtkwave $(WAVE_FILENAME) .gtkwaverc 1> /dev/null 2>& 1 &