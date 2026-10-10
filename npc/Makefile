TOPNAME := sCPU

NVBOARD_HOME ?= $(abspath ../nvboard)

BUILD_DIR := $(abspath build)
OBJ_DIR   := $(BUILD_DIR)/obj_dir
BIN		  := $(BUILD_DIR)/$(TOPNAME)

NV_BIN := $(BUILD_DIR)/sCPU-nvboard
NV_OBJ_DIR := $(BUILD_DIR)/obj_dir_nvboard
NV_RUN_DIR := $(BUILD_DIR)/nvboard_run
NV_PROGRAM := $(NV_RUN_DIR)/program.hex
NV_CONSTR := constr/sCPU.nxdc
NV_BIND := $(BUILD_DIR)/auto_bind.cpp
NV_MAIN := $(abspath csrc/nvboard_main.cc)

VSRCS	  := $(sort $(wildcard $(abspath vsrc)/*.v))
CSRCS     := $(sort $(wildcard $(abspath csrc)/*.cpp))

VERILATOR := verilator
VERILATOR_FLAGS := \
			--cc \
			--exe \
			--build \
			-Wall \
			--top-module $(TOPNAME) \
			--Mdir $(OBJ_DIR)

all: $(BIN)

$(BIN): $(VSRCS) $(CSRCS)
		@mkdir -p $(BUILD_DIR)
		$(VERILATOR) $(VERILATOR_FLAGS) \
			$(VSRCS) $(CSRCS) \
			-o $(BIN)

run: $(BIN) program.hex
	cd $(CURDIR) && $(BIN)

sim: $(BIN) program.hex
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	cd $(CURDIR) && $(BIN)

clean: 
	rm -rf $(BUILD_DIR)

.PHONY: all run sim clean nvboard-run

include $(NVBOARD_HOME)/scripts/nvboard.mk

$(NV_BIND): $(NV_CONSTR) $(NVBOARD_HOME)/scripts/auto_pin_bind.py
	@mkdir -p $(BUILD_DIR)
	NVBOARD_HOME="$(NVBOARD_HOME)" python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $(NV_CONSTR) $@

$(NV_PROGRAM): button_sum.s tools/assembler.py
	@mkdir -p $(NV_RUN_DIR)
	python3 tools/assembler.py button_sum.s -o $@
$(NV_BIN): $(VSRCS) $(NV_MAIN) $(NV_BIND) $(NVBOARD_ARCHIVE)
	$(VERILATOR) --cc --exe --build -Wall --top-module $(TOPNAME) \
	--Mdir $(NV_OBJ_DIR) \
	-CFLAGS "-I$(NVBOARD_HOME)/usr/include $(CXXFLAGS)" \
	$(VSRCS) $(NV_MAIN) $(NV_BIND) \
	-LDFLAGS "$(NVBOARD_ARCHIVE) $(LDFLAGS) \
	-o $@

nvboard-run: $(NV_BIN) $(NV_PROGRAM)
	cd $(NV_RUN_DIR) && NVBOARD_HOME="$(NVBOARD_HOME)" $(NV_BIN)

include ../Makefile
