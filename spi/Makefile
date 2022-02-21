CC = iverilog
FLAGS =-g2012 -Wall -Winfloop 

TOP_FILE=src/spi.v
TEST_BENCH_FILE=tb/spi_tb.v

OUTPUT_FILENAME=spi_tb.out
WAVE_FILENAME=spi_tb.vcd

INCLUDES=  src/spi_clock_generator.v src/spi_register.v src/spi_module.v src/edge_detector.v src/prescaler.v





compile: $(TOP_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(INCLUDES) $(TOP_FILE)


clean:
	rm -f $(WAVE_FILENAME) $(OUTPUT_FILENAME) 

vvp: $(TEST_BENCH_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(INCLUDES) $(TOP_FILE) $(TEST_BENCH_FILE) -s spi_tb
	
	vvp $(OUTPUT_FILENAME)

simulate: $(TEST_BENCH_FILE) clean vvp
	gtkwave $(WAVE_FILENAME) .gtkwaverc 1> /dev/null 2>& 1 &