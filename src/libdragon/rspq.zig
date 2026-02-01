// Basically removing prefixes from functions
const libdragon = @import("libdragon.zig");

extern fn free_block_glue(block: *libdragon.c.rspq_block_t) void;

pub fn block_begin() void {
    libdragon.c.rspq_block_begin();
}

pub fn block_run(block: *libdragon.c.rspq_block_t) void {
    libdragon.c.rspq_block_run(block);
}

pub fn block_end() *libdragon.c.rspq_block_t {
    return libdragon.c.rspq_block_end().?;
}

pub fn block_free(block: *libdragon.c.rspq_block_t) void {
    free_block_glue(block);
}
