// Basically removing prefixes from functions
const libdragon = @cImport({
    @cInclude("libdragon.h");
});

pub fn block_begin() void {
    libdragon.rspq_block_begin();
}

pub fn block_end() *libdragon.rspq_block_t {
    return libdragon.rspq_block_end();
}
