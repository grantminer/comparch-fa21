# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -Wall -g2012 -y ./ -I ./
VVP=vvp
VIVADO=vivado -mode batch -source

# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions

MUXES = mux32.sv mux16.sv mux8.sv mux4.sv mux2.sv

test_mux4: test_mux4.sv $(MUXES)
	${IVERILOG} $^ -o test_mux4.bin && ${VVP} test_mux4.bin

test_mux32: test_mux32.sv $(MUXES)
	${IVERILOG} $^ -o test_mux32.bin && ${VVP} test_mux32.bin

test_adder32: test_adder32.sv adder32.sv adder1.sv
	${IVERILOG} $^ -o test_adder32.bin && ${VVP} test_adder32.bin

test_adder32a: test_adder32a.sv adder32.sv adder1.sv
	${IVERILOG} $^ -o test_adder32a.bin && ${VVP} test_adder32a.bin

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd vivado*.log vivado*.jou vivado*.str

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md