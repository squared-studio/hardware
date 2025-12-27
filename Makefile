export SHELL=/bin/bash

####################################################################################################
# TOOLS
####################################################################################################

PYTHON ?= python

####################################################################################################
# VARIABLES
####################################################################################################

# Define the top module
TOP ?= soc

# Get the root directory
ROOT_DIR = $(shell echo $(realpath .))

# Default goal is to help
.DEFAULT_GOAL := help

# Define XVLOG_DEFS
XVLOG_DEFS += -d SIMULATION

# Define a command to grep for WARNING and ERROR messages with color highlighting
GREP_EW := grep -E "WARNING:|ERROR:|" --color=auto

TEST ?= default

SHA_ARGS += $$(find include/ -type f)
SHA_ARGS += $$(find package/ -type f)
SHA_ARGS += $$(find interface/ -type f)
SHA_ARGS += $$(find source/ -type f)
SHA_ARGS += $$(find testbench/ -type f)

GIT_UNAME := $(shell git config user.name)
GIT_UMAIL := $(shell git config user.email)

DBG ?= 0
ifeq ($(DBG), 1)
	XELAB_FLAGS += --debug all
endif

COV ?= 0
CC_COV ?= 0

ifeq ($(COV), 1)
ifeq ($(CC_COV), 1)
	XELAB_FLAGS += --cc_type -sbc
endif
endif

ifeq ($(COV), 1)
ifeq ($(CC_COV), 1)
	XCRG_FLAGS += -cc_db $(TOP) -cc_fullfile -cc_report cc_report
endif
endif

LINE_1 := This file is part of squared-studio:$(shell basename `git rev-parse --show-toplevel`)
LINE_2 := Copyright (c) $(shell date +%Y) squared-studio
LINE_3 := Licensed under the MIT License
LINE_4 := See LICENSE file in the project root for full license information


####################################################################################################
# PACKAGE LISTS
####################################################################################################

PACKAGE_LIST += ${ROOT_DIR}/package/dummy_pkg.sv

####################################################################################################
# TARGETS
####################################################################################################

# Help target: displays help message
.PHONY: help
help:
	@echo -e "\033[1;36mAvailable targets:\033[0m"
	@echo -e "\033[1;33m  clean          \033[0m- Removes build directory and rebuilds it"
	@echo -e "\033[1;33m  clean_full     \033[0m- Cleans both build and log directories"
	@echo -e "\033[1;33m  simulate       \033[0m- Compiles and simulates the design"
	@echo -e "\033[1;33m  simulate_gui   \033[0m- Compiles and simulates the design with GUI"
	@echo -e "\033[1;36mVariables:\033[0m"
	@echo -e "\033[1;33m  TOP            \033[0m- Specifies the top module to be used"
	@echo -e "\033[1;33m  TEST           \033[0m- Specifies the test case to simulate"

# Build target: creates build directory and adds it to gitignore
build:
	@echo -e "\033[3;35mCreating build directory...\033[0m"
	@mkdir -p build
	@echo "*" > build/.gitignore
	@git add build &> /dev/null
	@echo -e "\033[3;35mCreated build directory\033[0m"

# Log target: creates log directory and adds it to gitignore
log:
	@echo -e "\033[3;35mCreating log directory...\033[0m"
	@mkdir -p log
	@echo "*" > log/.gitignore
	@git add log &> /dev/null
	@echo -e "\033[3;35mCreated log directory\033[0m"

# Clean target: removes build directory and rebuilds it
.PHONY: clean
clean:
	@echo -e "\033[3;35mCleaning build directory...\033[0m"
	@rm -rf build
	@rm -f temp_ci_issues
	@echo -e "\033[3;35mCleaned build directory\033[0m"

.PHONY: clean_full
clean_full:
	@make -s clean
	@echo -e "\033[3;35mCleaning log directory...\033[0m"
	@rm -rf log
	@echo -e "\033[3;35mCleaned log directory\033[0m"

.PHONY: CHK_BUILD
CHK_BUILD:
	@if [ ! -f build/build_$(TOP) ]; then                    \
		echo -e "\033[3;33mEnvironment not built...\033[0m";   \
		make -s ENV_BUILD TOP=$(TOP);                          \
	else                                                     \
		echo -e "\033[3;33mChecking sha256sum...\033[0m";      \
		make -s match_sha TOP=$(TOP);                          \
	fi

.PHONY: match_sha
match_sha:
	@sha256sum ${SHA_ARGS} > build/build_$(TOP)_new
	@diff build/build_$(TOP)_new build/build_$(TOP) || make -s ENV_BUILD TOP=$(TOP)

.PHONY: ENV_BUILD
ENV_BUILD:
	@make -s clean
	@make -s build
	@echo -e "\033[3;35mCompiling...\033[0m"
	@echo "-i ${ROOT_DIR}/include" > build/flist
	@$(foreach file, $(PACKAGE_LIST), echo -e $(file) >> build/flist;)
	@find ${ROOT_DIR}/interface -type f >> build/flist
	@find ${ROOT_DIR}/source -type f >> build/flist
	@find ${ROOT_DIR}/testbench -type f >> build/flist
	@cd build; xvlog -sv -f flist --nolog $(XVLOG_DEFS) | $(GREP_EW)
	@echo -e "\033[3;35mCompiled\033[0m"
	@echo -e "\033[3;35mElaborating $(TOP)...\033[0m"
	@cd build; xelab $(TOP) --O0 --incr --nolog --timescale 1ns/1ps $(XELAB_FLAGS) | $(GREP_EW)
	@echo -e "\033[3;35mElaborated $(TOP)\033[0m"
	@sha256sum ${SHA_ARGS} > build/build_$(TOP)

.PHONY: common_sim_checks
common_sim_checks:
	@echo "--testplusarg TEST=$(TEST)" > build/xsim_args

.PHONY: simulate
simulate:
	@make -s log
	@make -s CHK_BUILD TOP=$(TOP)
	@make -s common_sim_checks
	@echo -e "\033[3;35mSimulating $(TOP) $(TEST)...\033[0m"
	@$(eval log_file_name := $(shell echo "$(TOP)_$(TEST).txt" | sed "s/\//___/g"))
	@cd build; xsim $(TOP) -f xsim_args -runall -log ../log/$(log_file_name)
	@echo -e "\033[3;35mSimulated $(TOP) $(TEST)\033[0m"
ifeq ($(COV), 1)
	@make -s coverage_reports
	@echo -e "\033[3;35mGenerating Coverage Report $(TOP)...\033[0m"
	@cd build; xcrg $(XCRG_FLAGS) -report_format html --nolog -cov_db_name work.$(TOP)
	@echo -e "\033[3;35mGenerated Coverage Report $(TOP)\033[0m"
	@mv build/xsim_coverage_report/functionalCoverageReport coverage_reports/$(TOP)_$(TEST)_fc
ifeq ($(CC_COV), 1)
	@mv build/cc_report/codeCoverageReport coverage_reports/$(TOP)_$(TEST)_cc
endif
endif

coverage_reports:
	@mkdir -p coverage_reports
	@echo "*" > coverage_reports/.gitignore

.PHONY: simulate_gui
simulate_gui:
	@make -s CHK_BUILD TOP=$(TOP)
	@make -s common_sim_checks
	@cd build; xsim $(TOP) -f xsim_args -gui --nolog

.PHONY: testbench
testbench:
ifeq ($(FILE),)
	@echo -e "\033[1;31mPlease enter FILE=\033[0m"
else
	@test -e testbench/$(FILE).sv ||                                             \
		(	                                                                         \
			cat template/testbench_template.sv	                                     \
			  | sed "s/^module testbench_template;$$/module $(FILE);/g"              \
			  | sed "s/^\/\/ Author :.*/\/\/ Author : $(GIT_UNAME) ($(GIT_UMAIL))/g" \
			  | sed "s/2023 squared-studio/$(shell date +%Y) squared-studio/g"       \
				> testbench/$(FILE).sv                                                 \
		)
	@code testbench/$(FILE).sv
endif

.PHONY: design
design:
ifeq ($(FILE),)
	@echo -e "\033[1;31mPlease enter FILE=\033[0m"
else
	@test -e source/$(FILE).sv ||                                                \
		(	                                                                         \
			cat template/design_template.sv	                                         \
			  | sed "s/^module design_template #($$/module $(FILE) #(/g"             \
			  | sed "s/^\/\/ Author :.*/\/\/ Author : $(GIT_UNAME) ($(GIT_UMAIL))/g" \
			  | sed "s/2023 squared-studio/$(shell date +%Y) squared-studio/g"       \
				> source/$(FILE).sv                                                    \
		)
	@code source/$(FILE).sv
endif

LINE_1 := This file is part of squared-studio : hardware
LINE_2 := Copyright (c) $(shell date +%Y) squared-studio
LINE_3 := Licensed under the MIT License
LINE_4 := See LICENSE file in the repository root for full license information

.PHONY: update_docs
update_docs:
	@mkdir -p document/source
	@rm -rf document/source/*.md
	@rm -rf document/source/*_top.svg
	@git submodule update --init --depth 1 -- documenter
	@for file in $$(find source -type f); do make -s gen_doc FILE="$$file"; done

.PHONY: gen_doc
gen_doc:
	@echo "Creating document for $(FILE)"
	@${PYTHON} documenter/sv_documenter.py $(FILE) document/source
	@sed -i "s/.*${LINE_1}.*/<br>**${LINE_1}**/g" document/source/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")
	@sed -i "s/.*${LINE_2}.*/<br>**${LINE_2}**/g" document/source/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")
	@sed -i "s/.*${LINE_3}.*/<br>**${LINE_3}**/g" document/source/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")
	@sed -i "s/.*${LINE_4}.*/<br>**${LINE_4}**/g" document/source/$(shell basename $(FILE) | sed "s/\.sv/\.md/g")

.PHONY: print_logo
print_logo:
	@echo -e "\033[1;37m                                    _         _             _ _       \033[0m"
	@echo -e "\033[1;37m ___  __ _ _   _  __ _ _ __ ___  __| |    ___| |_ _   _  __| (_) ___  \033[0m"
	@echo -e "\033[1;37m/ __|/ _' | | | |/ _' | '__/ _ \/ _' |___/ __| __| | | |/ _' | |/ _ \ \033[0m"
	@echo -e "\033[1;36m\__ \ (_| | |_| | (_| | | |  __/ (_| |___\__ \ |_| |_| | (_| | | (_) |\033[0m"
	@echo -e "\033[1;36m|___/\__, |\__,_|\__,_|_|  \___|\__,_|   |___/\__|\__,_|\__,_|_|\___/ \033[0m"
	@echo -e "\033[1;36m        |_|                                                2023-$(shell date +%Y)\033[0m\n"

.PHONY: copyright_check
copyright_check:
	@rm -rf ___temp
	@$(eval LIST := $(shell find -name "*.svh" | sed "s/\/.*sub\/.*//g"))
	@$(foreach file, $(LIST), $(call copyright_check_file,$(file));)
	@$(eval LIST := $(shell find -name "*.sv" | sed "s/\/.*sub\/.*//g"))
	@$(foreach file, $(LIST), $(call copyright_check_file,$(file));)
	@touch ___temp
	@cat ___temp
	@rm -rf ___temp

define copyright_check_file
	(grep -ir "author" $(1) > /dev/null) || (echo "$(1) >> \"Author : Name (email)\"" >> ___temp)
	(grep -r "$(LINE_1)" $(1) > /dev/null) || (echo "$(1) >> \"$(LINE_1)\"" >> ___temp)
	(grep -r "$(LINE_2)" $(1) > /dev/null) || (echo "$(1) >> \"$(LINE_2)\"" >> ___temp)
	(grep -r "$(LINE_3)" $(1) > /dev/null) || (echo "$(1) >> \"$(LINE_3)\"" >> ___temp)
	(grep -r "$(LINE_4)" $(1) > /dev/null) || (echo "$(1) >> \"$(LINE_4)\"" >> ___temp)
endef

.PHONY: verible_lint
verible_lint:
	@rm -rf ___LINT_ERROR
	@$(eval list := $(shell find -name "*.v" -o -name "*.sv"))
	@$(foreach file, $(list), verible-verilog-lint $(file) >> ___LINT_ERROR 2>&1 || true;)


.PHONY: lint
lint:
	@make -s verible_lint
	@cat ___LINT_ERROR
	@rm -rf ___LINT_ERROR