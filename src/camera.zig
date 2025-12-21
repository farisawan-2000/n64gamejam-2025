
const constants = @import("constants.zig");
const log = @import("logging.zig");

const tiny3d = @import("tiny3d/t3d.zig");
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Viewport = @import("tiny3d/viewport.zig").Viewport;

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
        self.viewport.set_projection(tiny3d.DEG_TO_RAD(85.0), 10.0, 150.0);
        self.viewport.look_at(
            .{.xyz = self.pos},
            .{.xyz = self.look},
            .{.xyz = .{0,1,0}}
        );
        self.viewport.attach();
    }

};
