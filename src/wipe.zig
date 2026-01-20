const libdragon = @import("libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

fn FloatApproach(dest: *f32, src: *f32, multiplier: f32) void {
    dest.* = dest.* + (src.* - dest.*) * multiplier;
}

pub const Wipe = struct {
    stage: f32,
    goal: f32,
    ready: bool,

    pub fn init() Wipe {
        return .{
            .stage = 0.0,
            .goal = 0.0,
            .ready = false,
        };
    }

    pub fn update(self: *Wipe) void {
        FloatApproach(&self.stage, &self.goal, 0.2);

        if (
                self.goal == 1.0
            and @abs(self.goal - self.stage) < 0.001
            and self.ready == false
        ) {
            self.goal = 0;
            self.ready = true;
        }
    }

    pub fn draw(self: *const Wipe) void {
        // const interp_from_left: f32 = 160 * self.stage;
        // const interp_from_top: f32 = 120 * self.stage;
        // const interp_from_right: f32 = 320 - (160 * self.stage);
        // const interp_from_bottom: f32 = 240 - (120 * self.stage);
        rdpq.set_combiner_mode_shade();
        rdpq.set_blend_mode_multiply();

        if (self.stage > 0.001) {
            // rdpq.set_prim_color(.{255, 255, 255, @intFromFloat(self.stage * 256)});

            rdpq.colortri(.{0, 0}, .{320, 0}, .{320, 240}, .{1.0, 1.0, 1.0, self.stage});
            rdpq.colortri(.{0, 0}, .{320, 240}, .{0, 240}, .{1.0, 1.0, 1.0, self.stage});

            // // top left
            // rdpq.triangle(.{0, 0}, .{160, 0}, .{interp_from_left, interp_from_top});
            // rdpq.triangle(.{0, 0}, .{0, 120}, .{interp_from_left, interp_from_top});
            // // top right
            // rdpq.triangle(.{160, 0}, .{320, 0}, .{interp_from_right, interp_from_top});
            // rdpq.triangle(.{0, 0}, .{0, 120}, .{interp_from_right, interp_from_top});
            // // bottom left
            // rdpq.triangle(.{interp_from_bottom, interp_from_left}, .{0, 240}, .{160, 240});
            // rdpq.triangle(.{interp_from_bottom, interp_from_left}, .{0, 240}, .{160, 120});
            // // bottom right
            // rdpq.triangle(.{interp_from_bottom, interp_from_right}, .{320, 240}, .{0, 240});
            // rdpq.triangle(.{interp_from_bottom, interp_from_right}, .{0, 0}, .{0, 120});
        }
    }
};

