TOPNAME := sCPU

BUILD_DIR := $(abspath build)
OBJ_DIR   := $(BUILD_DIR)/obj_dir
BIN		  := $(BUILD_DIR)/$(TOPNAME)

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

.PHONY: all run sim clean

include ../Makefile
