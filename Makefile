default: all

.PHONY: all

all:
	zig build --libc libc_paths.txt
