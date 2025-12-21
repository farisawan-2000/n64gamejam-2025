const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("malloc.h");
    @cInclude("string.h");
    @cInclude("stdint.h");
    @cInclude("contpad.h");
});

const libdragon = @import("libdragon/libdragon.zig");

const log = @import("logging.zig");

pub const ContPad = c.ContPad;

var pads: [4]ContPad = undefined;

pub fn update() void {
    pads = .{
        c.PollController(libdragon.c.JOYPAD_PORT_1),
        c.PollController(libdragon.c.JOYPAD_PORT_2),
        c.PollController(libdragon.c.JOYPAD_PORT_3),
        c.PollController(libdragon.c.JOYPAD_PORT_4)
    };
}

pub fn getPad(port: i32) ContPad {
    return pads[@bitCast(port - 1)];
}

