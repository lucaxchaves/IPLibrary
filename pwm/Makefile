CC = iverilog
FLAGS =-g2012 -Wall -Winfloop 

TOP_FILE=src/pwm.v
TEST_BENCH_FILE=tb/pwm_tb.v

OUTPUT_FILENAME=pwm_test.out
WAVE_FILENAME=pwm_test.vcd

INCLUDES= src/ tb/





compile: $(TOP_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(TOP_FILE) -I $(INCLUDES)


clean:
	rm -f $(WAVE_FILENAME) $(OUTPUT_FILENAME) 

vvp: $(TEST_BENCH_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(TEST_BENCH_FILE) -I $(INCLUDES)
	vvp $(OUTPUT_FILENAME)


simulate: $(TEST_BENCH_FILE) clean vvp
	gtkwave $(WAVE_FILENAME) .gtkwaverc 1> /dev/null 2>& 1 &