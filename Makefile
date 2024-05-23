# Compiler and simulator settings
SIMULATOR = vcs
SIM_FLAGS = -sverilog -full64
SIM_RUN_FLAGS = -R

# Source files
SRC_FILES = top.v top_tb_direct.v
SV_FILES = assertion.sv coverage.sv driver.sv environment.sv generator.sv interface.sv monitor.sv scoreboard.sv test.sv transaction.sv defines.sv

# Compile target
compile:
	$(SIMULATOR) $(SIM_FLAGS) $(SV_FILES) $(SRC_FILES)

# Run simulation target
simulate: compile
	./simv $(SIM_RUN_FLAGS)

# Clean target
clean:
	rm -rf csrc simv* *.daidir

.PHONY: compile simulate clean
