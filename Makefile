default: all

.PHONY: all clean

BUILD_DIR = build
N64_OBJDUMP = /opt/crashsdk/bin/mips-n64-objdump
# N64_INST = /opt/crashsdk
# include libdragon-unstable/n64.mk

# We installed this on arch linux
T3D_INST=/usr/include

include $(N64_INST)/include/n64.mk
include $(T3D_INST)/t3d.mk

ROM := game.z64


CFLAGS += -g -ggdb3

all: $(ROM)

$(BUILD_DIR)/:
	mkdir -p $@

DUMMY != mkdir -p $(BUILD_DIR)/src

C_SRCS := $(wildcard src/*.c)
ZIG_SRCS := src/main.zig

build/src/main.o: $(wildcard src/**/*.zig) $(wildcard src/*.zig)

OBJS := $(C_SRCS:%.c=$(BUILD_DIR)/%.o) $(ZIG_SRCS:%.zig=$(BUILD_DIR)/%.o)

ZIG_INCLUDES += -I/usr/mips64-elf/include/ -Isrc/ -I.

NO_WARNINGS := -Wno-unused-const-variable -Wno-incompatible-pointer-types -Wno-unused-but-set-variable -Wno-main -Wno-return-type \
               -Wno-unused-function -Wno-unused-variable

assets_png = $(wildcard assets/*.png)
assets_gltf = $(wildcard assets/*.glb)
assets_ttf = $(wildcard assets/*.ttf)

ASSET_CONV = $(addprefix filesystem/,$(notdir $(assets_png:%.png=%.sprite))) \
			  $(addprefix filesystem/,$(notdir $(assets_ttf:%.ttf=%.font64))) \
			  $(addprefix filesystem/,$(notdir $(assets_gltf:%.glb=%.t3dm)))

filesystem/%.sprite: assets/%.png
	@mkdir -p $(dir $@)
	@echo "    [SPRITE] $@"
	$(N64_MKSPRITE) $(MKSPRITE_FLAGS) -o filesystem "$<"

filesystem/%.lvl: assets/%.lvl
	@mkdir -p $(dir $@)
	@echo "    [LEVEL] $@"
	cp $< $@

filesystem/%.font64: assets/%.ttf
	@mkdir -p $(dir $@)
	@echo "    [FONT] $@"
	$(N64_MKFONT) $(MKFONT_FLAGS) -s 9 -o filesystem "$<"

filesystem/%.t3dm: assets/%.glb
	@mkdir -p $(dir $@)
	@echo "    [T3D-MODEL] $@"
	$(T3D_GLTF_TO_3D) "$<" $@
	$(N64_BINDIR)/mkasset -c 2 -w 256 -o filesystem $@

# Compile Zig code
$(BUILD_DIR)/%.o: %.zig | $(BUILD_DIR)/
	@echo "    [ZIG] $@"
	zig build-obj $< \
	              -target mips-freestanding-gnu -mcpu=mips2 -lc -D__MIPSEB__ -Dwint_t=long \
	              $(ZIG_INCLUDES) -ofmt=c -femit-bin=$@.c \
	              -fomit-frame-pointer
	$(CC) -c $(CFLAGS) $(NO_WARNINGS) -I /usr/lib/zig/ -o $@ $@.c

$(ROM): N64_ROM_TITLE = "Credits"
$(ROM): $(BUILD_DIR)/game.dfs

$(BUILD_DIR)/game.dfs: $(wildcard filesystem/*) $(ASSET_CONV)
$(BUILD_DIR)/game.elf: $(OBJS) | $(BUILD_DIR)/

clean:
	@echo "    [CLEAN] build/"
	rm -rf $(BUILD_DIR)/

libs:
	$(MAKE) -C libdragon-unstable/

test: $(ROM)
	ares $<

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true

