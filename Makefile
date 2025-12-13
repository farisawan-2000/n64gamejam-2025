default: all

.PHONY: all clean

BUILD_DIR = build
N64_OBJDUMP = /opt/crashsdk/bin/mips-n64-objdump
# N64_INST = /opt/crashsdk
# include libdragon-unstable/n64.mk

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

TRANSFORM := -ofmt=c
# TRANSFORM := -femit-llvm-ir
# Compile Zig code
$(BUILD_DIR)/%.o: %.zig | $(BUILD_DIR)/
	@echo "    [ZIG] $@"
	cpp -P $(CPPFLAGS) $< -o $(BUILD_DIR)/$*.zig
	zig build-obj $(BUILD_DIR)/$*.zig \
	              -target mips-freestanding-gnu -mcpu=mips2 -lc \
	              $(ZIG_INCLUDES) $(TRANSFORM) -femit-bin=$@.c \
	              -fomit-frame-pointer
	$(CC) -c $(CFLAGS) -Wno-incompatible-pointer-types -I /usr/lib/zig/ -o $@ $@.c
# 	$(N64_OBJCOPY) --remove-section .MIPS.abiflags $@
# 	$(N64_OBJCOPY) --remove-section .MIPS.options $@
# 	python3 tools/set_o32abi_bit.py $@

$(ROM): N64_ROM_TITLE = "Video game"
$(ROM): $(BUILD_DIR)/game.dfs

$(BUILD_DIR)/game.dfs: $(wildcard filesystem/*)
$(BUILD_DIR)/game.elf: $(OBJS) | $(BUILD_DIR)/

clean:
	@echo "    [CLEAN] build/"
	rm -rf $(BUILD_DIR)/
	@echo "    [CLEAN] libdragon-unstable/"
	$(MAKE) -C libdragon-unstable clean

libs:
	$(MAKE) -C libdragon-unstable/

test: $(ROM)
	ares $<

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true

