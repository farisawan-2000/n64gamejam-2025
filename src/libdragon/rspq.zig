// Basically removing prefixes from functions
const libdragon = @cImport({
    @cInclude("libdragon.h");
});

pub fn block_begin() void {
    libdragon.rspq_block_begin();
}
