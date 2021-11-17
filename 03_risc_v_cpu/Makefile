# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y ./ -I ./
VVP=vvp
VVP_POST=-vcd
VIVADO=vivado -mode batch -source

SRCS = register_file.sv tests/test_register_file.sv
RESULTS = test_results/*

test_register_file: ${SRCS}
	${IVERILOG} $^ -o test_results/test_register_file.bin && ${VVP} test_results/test_register_file.bin ${VVP_POST}

waves_register_file: test_register_file
	gtkwave test_results/register_file.vcd -a test_register_file.gtkw


# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions

main.bit: main.sv $(MAIN_SRCS) memories/ili9341_init.memh build.tcl
	@echo "########################################"
	@echo "#### Building FPGA bitstream        ####"
	@echo "########################################"
	${VIVADO} build.tcl

program_fpga_vivado: main.bit build.tcl program.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Vivado)      ####"
	@echo "########################################"
	${VIVADO} program.tcl

program_fpga_digilent: main.bit build.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Digilent)    ####"
	@echo "########################################"
	djtgcfg enum
	djtgcfg prog -d CmodA7 -i 0 -f main.bit


# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml
	rm -rf .Xil

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md docs/* *.tcl *.xdc tests/*.sv *.pdf
