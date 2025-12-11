default: all

.PHONY: all clean

BUILD_DIR = build
include $(N64_INST)/include/n64.mk

ROM := game.z64

all: $(ROM)

$(BUILD_DIR)/:
	mkdir -p $@

DUMMY != mkdir -p $(BUILD_DIR)/src

C_SRCS := $(wildcard src/*.c)
ZIG_SRCS := $(wildcard src/*.zig)

OBJS := $(C_SRCS:%.c=$(BUILD_DIR)/%.o) $(ZIG_SRCS:%.zig=$(BUILD_DIR)/%.o)

ZIG_INCLUDES += -I/usr/mips64-elf/include/

# Compile Zig code
$(BUILD_DIR)/%.o: %.zig | $(BUILD_DIR)/
	$(call print,Compiling:,$<,$@)
	cpp -P $(CPPFLAGS) $< -o $(BUILD_DIR)/$*.zig
	zig build-obj $(BUILD_DIR)/$*.zig -target mips-freestanding-gnu -lc $(ZIG_INCLUDES) -femit-bin=$@
	python3 tools/set_o32abi_bit.py $@

game.z64: N64_ROM_TITLE = "Video game"
game.z64: $(BUILD_DIR)/game.dfs

$(BUILD_DIR)/game.dfs: $(wildcard filesystem/*)
$(BUILD_DIR)/game.elf: $(OBJS) | $(BUILD_DIR)/

clean:
	rm -rf $(BUILD_DIR)/

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true

