const libdragon = @import("libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

pub const Wipe = struct {
    stage: f32,
    goal: f32,
    // state: u32,

    pub fn init() Wipe {
        return .{
            .stage = 0.0,
            .goal = 0.0,
        };
    }

    pub fn update(self: *Wipe) void {
        _ = self;
    }

    pub fn draw(self: *const Wipe) void {
        if (self.stage != 0) {
            rdpq.set_combiner_mode_flat();
            rdpq.set_prim_color(.{255, 255, 255, 0});
            rdpq.triangle(.{0, 0}, .{160, 0}, .{160, 120});
            rdpq.triangle(.{0, 0}, .{0, 120}, .{160, 120});
        }
    }
};

