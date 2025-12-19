// Basically removing prefixes from functions
const libdragon = @import("libdragon.zig");

pub fn attach(cfb: *libdragon.c.surface_t, zbuf: *libdragon.c.surface_t) void {
    libdragon.c.rdpq_attach(cfb, zbuf);
}

pub fn detach_show() void {
    libdragon.c.rdpq_detach_show();
}
