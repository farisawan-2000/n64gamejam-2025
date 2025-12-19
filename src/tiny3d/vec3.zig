const t3d = @import("t3d.zig");

pub const Vec3 = struct {
    xyz: [3]f32,

    pub fn init(xyz: [3]f32) Vec3 {
        return .{
            .xyz = xyz,
        };
    }

    pub fn normalize(self: *const Vec3) void {
        var exported = self.export_t3d();

        t3d.c.t3d_vec3_norm(&exported);
    }

    // Constructs a T3DVec3 from a [3]f32 so that we can talk to C
    pub fn export_t3d(self: *const Vec3) t3d.c.T3DVec3 {
        var ret: t3d.c.T3DVec3 = undefined;
        ret.v = .{self.xyz[0], self.xyz[1], self.xyz[2]};

        return ret;
    }
};

