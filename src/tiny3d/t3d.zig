// Basically so that we NEVER have to call extern c code outside of here
const c = @cImport({
    @cInclude("t3d/t3d.h");
    @cInclude("t3d/t3dmath.h");
    @cInclude("t3d/t3dmodel.h");
    @cInclude("t3d/t3dskeleton.h");
    @cInclude("t3d/t3danim.h");
});

// Constructs a T3DVec3 from a [3]f32 so that we can talk to C
fn T3DVec3(xyz: [3]f32) c.T3DVec3 {
    var ret: c.T3DVec3 = undefined;
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
    vp: c.T3DViewport,

    pub fn create(num_framebuffers: u16) Viewport {
        return .{
            .vp = c.t3d_viewport_create_buffered(num_framebuffers),
        };
    }

    pub fn set_projection(self: *Viewport, fov: f32, near: f32, far: f32) void {
        c.t3d_viewport_set_projection(&self.vp, fov, near, far);
    }

    pub fn look_at(self: *Viewport, eye: [3]f32, look: [3]f32, up: [3]f32) void {
        var eye_vec = T3DVec3(eye);
        var look_vec = T3DVec3(look);
        var up_vec = T3DVec3(up);
        c.t3d_viewport_look_at(&self.vp, &eye_vec, &look_vec, &up_vec);
    }

    pub fn attach(self: *Viewport) void {
        c.t3d_viewport_attach(&self.vp);
    }
};
