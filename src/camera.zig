
const constants = @import("constants.zig");
const log = @import("logging.zig");

const contpad = @import("contpad.zig");

const tiny3d = @import("tiny3d/t3d.zig");
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Viewport = @import("tiny3d/viewport.zig").Viewport;

fn VectorApproach(dest: *[3]f32, src: [3]f32, multiplier: f32) void {
    for (0 .. 2) |i| {
        dest[i] = dest[i] + (src[i] - dest[i]) * multiplier;
    }
}

pub const Camera = struct {
    pos: [3]f32,
    posTarget: [3]f32,
    look: [3]f32,
    lookTarget: [3]f32,

    viewport: Viewport,

    pub fn init(
        position: [3]f32,
        lookat_pos: [3]f32,
    ) Camera {
        return .{
            .pos = position,
            .posTarget = position,
            .look = lookat_pos,
            .lookTarget = lookat_pos,

            .viewport = Viewport.create(constants.FB_COUNT),
        };
    }

    pub fn update(self: *Camera) void {
        const pad = contpad.getPad(1);

        self.posTarget[0] += @as(f32, @floatFromInt(pad.stick_x)) / 20.0;
        self.posTarget[2] += @as(f32, @floatFromInt(pad.stick_y)) / 20.0;

        VectorApproach(&self.pos, self.posTarget, 0.25);
        VectorApproach(&self.look, self.lookTarget, 0.25);

        if (pad.a) {
            self.posTarget[1] += 1.0;
        }
        if (pad.b) {
            self.posTarget[1] -= 1.0;
        }

        self.viewport.set_projection(tiny3d.DEG_TO_RAD(85.0), 10.0, 150.0);
        self.viewport.look_at(
            .{.xyz = self.pos},
            .{.xyz = self.look},
            .{.xyz = .{0,1,0}}
        );
        self.viewport.attach();
    }

};
