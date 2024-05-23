# Makefile for SystemVerilog project

# Define file paths
RTL = ./top.sv
INTERFACE = ./interface.sv
TRANSACTION = ./transaction.sv
GENERATOR = ./generator.sv
DRIVER = ./driver.sv
MONITOR = ./monitor.sv
SCOREBOARD = ./scoreboard.sv
ENVIRONMENT = ./environment.sv
TEST = ./test.sv
DEFINES = ./defines.sv

# Seed for randomization
SEED = 1

# Default target
default: test

# Test target
test: compile run

# Run simulation
run:
	./simv -l simv.log +ntb_random_seed=$(SEED)

# Compile files
compile:
	vcs -l vcs.log -sverilog -debug_acc+all -debug_region+cell+encrypt -full64 $(DEFINES) $(INTERFACE) $(TRANSACTION) $(GENERATOR) $(DRIVER) $(MONITOR) $(SCOREBOARD) $(ENVIRONMENT) $(TEST) $(RTL)

# DVE for post-processing
dve:
	dve -vpd vcdplus.vpd &

# Debug mode
debug:
	./simv -l simv.log -gui -tbug +ntb_random_seed=$(SEED)

# Copy solution files
solution: clean
	cp ../../solutions/lab1/*.sv .

# Clean intermediate files
clean:
	rm -rf simv* csrc* *.tmp *.vpd *.key *.log *hdrs.h

# Nuke all changes
nuke: clean
	rm -rf *.v* *.sv include .*.lock .*.old DVE* *.tcl *.h
	cp .orig/* .

# Help message
help:
	@echo ==========================================================================
	@echo  " 								       "
	@echo  " USAGE: make target <SEED=xxx>                                         "
	@echo  " 								       "
	@echo  " ------------------------- Test TARGETS ------------------------------ "
	@echo  " test       => Compile TB and DUT files, runs the simulation.          "
	@echo  " compile    => Compile the TB and DUT.                                 "
	@echo  " run        => Run the simulation.                                     "
	@echo  " dve        => Run dve in post-processing mode                         "
	@echo  " debug      => Runs simulation interactively with dve                  "
	@echo  " clean      => Remove all intermediate simv and log files.             "
	@echo  "                                                                       "
	@echo  " -------------------- ADMINISTRATIVE TARGETS ------------------------- "
	@echo  " help       => Displays this message.                                  "
	@echo  " solution   => Copies all files from solutions directory               "
	@echo  " nuke       => Erase all changes. Put all files back to original state "
	@echo  "								       "
	@echo ==========================================================================
