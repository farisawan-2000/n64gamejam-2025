Depends on libdragon unstable (`libdragon-unstable-git` and `libdragon-tools-unstable-git` on AUR)

Built on Zig 0.15.2 (If you're reading this and 0.16 is out, I still have no clue if it works)

Two main changes need to be made to libdragon post-install:
- In `/usr/mips64-elf/include/emux.h`, replace all instances of `asm("$reg")` with `asm("reg")` (i.e. remove the dollar sign).
- In `/usr/include/n64.mk`, remove `-Werror`.

run `make` to build the rest


