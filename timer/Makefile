CC = iverilog
FLAGS =-g2012 -Wall -Winfloop 

TOP_FILE=src/timer.v
TEST_BENCH_FILE=src/timer_tb.v
OUTPUT_FILENAME=timer_tb.out
WAVE_FILENAME=timer_tb.vcd


OBJECTS := $(addprefix $(BUILDDIR)/,$(SOURCES:%.c=%.o))

INCLUDES= src/timer.v src/timer_register.v src/up_down_counter.v src/prescaler.v src/timer_output_controller.v src/timer_input_controller.v





compile: $(TOP_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(TOP_FILE) -I $(INCLUDES)


clean:
	rm -f $(WAVE_FILENAME) $(OUTPUT_FILENAME) 

vvp: $(TEST_BENCH_FILE) clean
	$(CC) $(FLAGS) -o $(OUTPUT_FILENAME) $(TEST_BENCH_FILE) $(INCLUDES)
	vvp $(OUTPUT_FILENAME)


simulate: $(TEST_BENCH_FILE) clean vvp
	gtkwave $(WAVE_FILENAME) .gtkwaverc 1> /dev/null 2>& 1 &