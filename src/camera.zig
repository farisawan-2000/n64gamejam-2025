const constants = @import("constants.zig");
const log = @import("logging.zig");

const contpad = @import("contpad.zig");

const tiny3d = @import("tiny3d/t3d.zig");
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Viewport = @import("tiny3d/viewport.zig").Viewport;

const math = @import("math.zig");

fn VectorApproach(dest: *[3]f32, src: [3]f32, multiplier: f32) void {
    for (dest, src) |*a, b| {
        a.* = a.* + (b - a.*) * multiplier;
    }
}

fn VectorExtend(dest: *[3]f32, src: [3]f32, dist: f32, pitch: f32, yaw: f32) void {
    dest[0] = src[0] + dist * tiny3d.c.cosf(tiny3d.DEG_TO_RAD(pitch)) * tiny3d.c.sinf(tiny3d.DEG_TO_RAD(yaw));
    dest[1] = src[1] + dist * tiny3d.c.sinf(tiny3d.DEG_TO_RAD(pitch));
    dest[2] = src[2] + dist * tiny3d.c.cosf(tiny3d.DEG_TO_RAD(pitch)) * tiny3d.c.cosf(tiny3d.DEG_TO_RAD(yaw));
}

pub const Mode = enum(usize) {
    @"Free Camera Movement" = 0,
    @"Focus On One Subject" = 1,
    @"Focus Between 2 Subjects" = 2,
};

pub fn mode_freecam(self: *Camera) void {
    const pad = contpad.getPad(1);

    if (pad.pressed.c_left) {
        self.yaw += 45;
    }
    if (pad.pressed.c_right) {
        self.yaw -= 45;
    }

    if (pad.held.c_up) {
        self.pitch += 1;
    }
    if (pad.held.c_down) {
        self.pitch -= 1;
    }

    math.degree_clamp(&self.yaw);
}

pub const Camera = struct {
    pos: [3]f32,
    posTarget: [3]f32,
    look: [3]f32,
    lookTarget: [3]f32,
    pitch: f32,
    yaw: f32,

    viewport: Viewport,

    pub fn init(
        position: [3]f32,
        lookat_pos: [3]f32,
    ) Camera {
        log.logVec(position);
        log.logVec(lookat_pos);
        return .{
            .pos = position,
            .posTarget = position,

            .look = lookat_pos,
            .lookTarget = lookat_pos,

            .pitch = 0,
            .yaw = 0,

            .viewport = Viewport.create(constants.FB_COUNT),
        };
    }

    pub fn update(self: *Camera) void {
        // var lookat: [3]f32 = undefined;
        VectorExtend(&self.posTarget,
            self.lookTarget,
            1000.0,
            self.pitch,
            self.yaw
        );

        VectorApproach(&self.pos, self.posTarget, 0.25);
        VectorApproach(&self.look, self.lookTarget, 0.25);

        self.viewport.set_projection(tiny3d.DEG_TO_RAD(45.0), 100.0, 8000.0);
        self.viewport.look_at(
            .{.xyz = self.pos},
            .{.xyz = self.look},
            .{.xyz = .{0,1,0}}
        );
        self.viewport.attach();
    }

};
