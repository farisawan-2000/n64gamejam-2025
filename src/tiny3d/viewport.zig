const t3d = @import("t3d.zig");
const Vec3 = @import("vec3.zig").Vec3;

pub const Viewport = struct {
    vp: t3d.c.T3DViewport,

    pub fn create(num_framebuffers: u16) Viewport {
        return .{
            .vp = t3d.c.t3d_viewport_create_buffered(num_framebuffers),
        };
    }

    pub fn set_projection(self: *Viewport, fov: f32, near: f32, far: f32) void {
        t3d.c.t3d_viewport_set_projection(&self.vp, fov, near, far);
    }

    pub fn look_at(self: *Viewport, eye: Vec3, look: Vec3, up: Vec3) void {
        var eye_vec = eye.export_t3d();
        var look_vec = look.export_t3d();
        var up_vec = up.export_t3d();
        t3d.c.t3d_viewport_look_at(&self.vp, &eye_vec, &look_vec, &up_vec);
    }

    pub fn attach(self: *Viewport) void {
        t3d.c.t3d_viewport_attach(&self.vp);
    }
};
