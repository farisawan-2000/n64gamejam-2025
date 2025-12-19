// Basically removing prefixes from functions
const libdragon = @import("libdragon.zig");

pub fn block_begin() void {
    libdragon.c.rspq_block_begin();
}

pub fn block_run(block: *libdragon.c.rspq_block_t) void {
    libdragon.c.rspq_block_run(block);
}

pub fn block_end() *libdragon.c.rspq_block_t {
    return libdragon.c.rspq_block_end().?;
}
