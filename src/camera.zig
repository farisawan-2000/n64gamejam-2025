
const constants = @import("constants.zig");
const log = @import("logging.zig");

const contpad = @import("contpad.zig");

const tiny3d = @import("tiny3d/t3d.zig");
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Viewport = @import("tiny3d/viewport.zig").Viewport;

fn VectorApproach(dest: *[3]f32, src: [3]f32, multiplier: f32) void {
    for (dest, src) |*a, b| {
        a.* = a.* + (b - a.*) * multiplier;
    }
}

// TODO: use rotation to generate lookat

pub const Camera = struct {
    pos: [3]f32,
    posTarget: [3]f32,
    rot: [3]f32,
    rotTarget: [3]f32,

    viewport: Viewport,

    pub fn init(
        position: [3]f32,
    ) Camera {
        return .{
            .pos = position,
            .posTarget = position,

            .rot = .{0, 0, 0},
            .rotTarget = .{0, 0, 0},

            .viewport = Viewport.create(constants.FB_COUNT),
        };
    }

    pub fn update(self: *Camera) void {
        const pad = contpad.getPad(1);

        self.posTarget[0] += @as(f32, @floatFromInt(pad.stick_x)) / 20.0;
        self.posTarget[2] += @as(f32, @floatFromInt(pad.stick_y)) / 20.0;

        VectorApproach(&self.pos, self.posTarget, 0.25);

        // if (pad.held.a) {
        //     self.posTarget[1] += 1.0;
        // }
        // if (pad.held.b) {
        //     self.posTarget[1] -= 1.0;
        // }

        self.viewport.set_projection(tiny3d.DEG_TO_RAD(85.0), 10.0, 150.0);
        self.viewport.look_at(
            .{.xyz = self.pos},
            .{.xyz = .{0, 0, 0}},
            .{.xyz = .{0,1,0}}
        );
        self.viewport.attach();
    }

};
