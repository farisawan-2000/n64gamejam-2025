pub const c = @cImport({
    @cInclude("libdragon.h");
    @cInclude("graphics.h");
});

pub const rspq = @import("rspq.zig");
pub const rdpq = @import("rdpq.zig");


