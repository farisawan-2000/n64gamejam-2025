// Basically so that we NEVER have to call extern c code outside of here
const t3d = @cImport({
    @cInclude("t3d/t3d.h");
    @cInclude("t3d/t3dmath.h");
    @cInclude("t3d/t3dmodel.h");
    @cInclude("t3d/t3dskeleton.h");
    @cInclude("t3d/t3danim.h");
});

fn T3DVec3(xyz: [3]f32) t3d.T3DVec3 {
    var ret: t3d.T3DVec3 = undefined;
    ret.v = .{xyz[0], xyz[1], xyz[2]};

    return ret;
}

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

pub const Viewport = struct {
    vp: t3d.T3DViewport,

    pub fn create(num_framebuffers: u16) Viewport {
        return .{
            .vp = t3d.t3d_viewport_create_buffered(num_framebuffers),
        };
    }

    pub fn set_projection(self: *Viewport, fov: f32, near: f32, far: f32) void {
        t3d.t3d_viewport_set_projection(&self.vp, fov, near, far);
    }

    pub fn look_at(self: *Viewport, eye: [3]f32, look: [3]f32, up: [3]f32) void {
        var eye_vec = T3DVec3(eye);
        var look_vec = T3DVec3(look);
        var up_vec = T3DVec3(up);
        t3d.t3d_viewport_look_at(&self.vp, &eye_vec, &look_vec, &up_vec);
    }

    pub fn attach(self: *Viewport) void {
        t3d.t3d_viewport_attach(&self.vp);
    }
};
