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

fn VectorExtend(dest: *[3]f32, src: [3]f32, dist: f32, pitch: f32, yaw: f32) void {
    dest[0] = src[0] + dist * tiny3d.c.cosf(tiny3d.DEG_TO_RAD(pitch)) * tiny3d.c.sinf(tiny3d.DEG_TO_RAD(yaw));
    dest[0] = src[0] + dist * tiny3d.c.sinf(tiny3d.DEG_TO_RAD(pitch));
    dest[0] = src[0] + dist * tiny3d.c.cosf(tiny3d.DEG_TO_RAD(pitch)) * tiny3d.c.cosf(tiny3d.DEG_TO_RAD(yaw));
}

// TODO: use rotation to generate lookat

const RPY = enum(usize) {
    roll,
    pitch,
    yaw,
};

pub const Camera = struct {
    pos: [3]f32,
    posTarget: [3]f32,
    rot: [3]f32,
    rotTarget: [3]f32,

    viewport: Viewport,

    pub fn init(
        position: [3]f32,
        rotation: [3]f32,
    ) Camera {
        log.logVec(position);
        log.logVec(rotation);
        return .{
            .pos = position,
            .posTarget = position,

            .rot = rotation,
            .rotTarget = rotation,

            .viewport = Viewport.create(constants.FB_COUNT),
        };
    }

    pub fn update(self: *Camera) void {
        const pad = contpad.getPad(1);

        self.posTarget[0] += @as(f32, @floatFromInt(pad.stick_x)) / 20.0;
        self.posTarget[2] += @as(f32, @floatFromInt(-pad.stick_y)) / 20.0;


        if (pad.held.c_left) {
            self.rotTarget[@intFromEnum(RPY.yaw)] += 1.0;
        }
        if (pad.held.c_right) {
            self.rotTarget[@intFromEnum(RPY.yaw)] -= 1.0;
        }
        if (pad.held.c_up) {
            self.rotTarget[@intFromEnum(RPY.pitch)] += 0.25;
            if (self.rotTarget[@intFromEnum(RPY.pitch)] > 180.0) {
                self.rotTarget[@intFromEnum(RPY.pitch)] = 180.0;
            }
        }
        if (pad.held.c_down) {
            self.rotTarget[@intFromEnum(RPY.pitch)] -= 0.25;
            if (self.rotTarget[@intFromEnum(RPY.pitch)] < 0) {
                self.rotTarget[@intFromEnum(RPY.pitch)] = 0;
            }
        }

        VectorApproach(&self.pos, self.posTarget, 0.25);
        VectorApproach(&self.rot, self.rotTarget, 0.25);


        var lookat: [3]f32 = undefined;
        VectorExtend(&lookat,
            self.pos,
            1000.0,
            self.rot[@intFromEnum(RPY.pitch)],
            self.rot[@intFromEnum(RPY.yaw)]
        );

        self.viewport.set_projection(tiny3d.DEG_TO_RAD(45.0), 50.0, 800.0);
        self.viewport.look_at(
            .{.xyz = self.pos},
            .{.xyz = self.rot},
            .{.xyz = .{0,1,0}}
        );
        self.viewport.attach();
    }

};
