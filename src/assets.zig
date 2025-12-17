const libdragon = @cImport({
    @cInclude("libdragon.h");
});

// Function becomes comptime automagically, thanks Zig!
pub fn init_compression(level: i32) void {
    switch (level) {
        0, 1 => {},
        2 => libdragon.__asset_init_compression_lvl2(),
        3 => libdragon.__asset_init_compression_lvl3(),
        else => {},
    }
}
