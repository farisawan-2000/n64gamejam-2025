pub const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("libdragon.h");
    @cInclude("graphics.h");
    @cInclude("rspq.h");
    @cInclude("rdpq.h");
});

pub const rspq = @import("rspq.zig");
pub const rdpq = @import("rdpq.zig");
pub const display = @import("display.zig");

