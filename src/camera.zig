const std = @import("std");
const constants = @import("constants.zig");
const log = @import("logging.zig");

const contpad = @import("contpad.zig");

const tiny3d = @import("tiny3d/t3d.zig");
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Viewport = @import("tiny3d/viewport.zig").Viewport;

const math = @import("math.zig");

pub const Mode = enum(usize) {
    @"Fixed Camera" = 0,
    @"Free Camera Movement" = 1,
    @"Focus On One Subject" = 2,
    @"Focus Between 2 Subjects" = 3,
};

pub fn token_to_mode(token: [:0]const u8) Mode {
    if (std.mem.eql(u8, token, "freecam")) {
        return .@"Free Camera Movement";
    }
    else if (std.mem.eql(u8, token, "fixed")) {
        return .@"Fixed Camera";
    }
    else if (std.mem.eql(u8, token, "main")) {
        return .@"Focus Between 2 Subjects";
    } else {
        unreachable;
    }
}

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

    self.posTarget[1] = self.height;

    math.degree_clamp(&self.yaw);
}

pub const Camera = struct {
    pos: [3]f32,
    posTarget: [3]f32,
    look: [3]f32,
    lookTarget: [3]f32,
    pitch: f32,
    yaw: f32,
    height: f32,
    distance: f32,

    viewport: Viewport,
    mode: Mode,

    pub fn init(
        position: [3]f32,
        lookat_pos: [3]f32,
    ) Camera {
        log.logVec(position);
        log.logVec(lookat_pos);
        return .{
            .mode = .@"Fixed Camera",
            .pos = position,
            .posTarget = position,
            .height = 0,
            .distance = 1000,

            .look = lookat_pos,
            .lookTarget = lookat_pos,

            .pitch = 0,
            .yaw = 0,

            .viewport = Viewport.create(constants.FB_COUNT),
        };
    }

    pub fn update(self: *Camera) void {
        // var lookat: [3]f32 = undefined;
        switch (self.mode) {
            .@"Fixed Camera" => {
                // Do nothing
            },
            .@"Free Camera Movement" => {
                mode_freecam(self);
            },
            .@"Focus On One Subject" => {
                // Do nothing for now
            },
            .@"Focus Between 2 Subjects" => {
                VectorExtend(&self.posTarget,
                    self.lookTarget,
                    self.distance,
                    self.pitch,
                    self.yaw
                );

                self.posTarget[1] = self.height;
                VectorApproach(&self.pos, self.posTarget, 0.25);
                VectorApproach(&self.look, self.lookTarget, 0.25);
            },
        }

        self.viewport.set_projection(tiny3d.DEG_TO_RAD(45.0), 100.0, 2000.0);
        self.viewport.look_at(
            .{.xyz = self.pos},
            .{.xyz = self.look},
            .{.xyz = .{0,1,0}}
        );

        self.viewport.attach();
    }

};
