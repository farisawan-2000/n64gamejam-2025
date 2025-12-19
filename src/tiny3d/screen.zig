const t3d = @import("t3d.zig");

pub const Screen = struct {
    bgcolor: [4]u8,

    pub fn make(rgba: [4]u8) Screen {
        return .{
            .bgcolor = rgba,
        };
    }

    pub fn clear(self: *const Screen) void {
        t3d.c.t3d_screen_clear_color(t3d.c.RGBA32(
            self.bgcolor[0],
            self.bgcolor[1],
            self.bgcolor[2],
            self.bgcolor[3]
        ));
    }

    pub fn clear_depth(self: *const Screen) void {
        _ = self;
        t3d.c.t3d_screen_clear_depth();
    }
};
