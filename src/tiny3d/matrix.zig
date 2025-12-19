const t3d = @import("t3d.zig");



pub const Matrix4 = struct {
    scale:       [3]f32,
    rotation:    [3]f32,
    translation: [3]f32,

    // export to fixed point
    fn export_t3d_fixedpoint() t3d.c.T3DMat4FP {

    }

    pub fn push(self: *const Matrix) void {

        t3d.c.t3d_matrix_push(self.fixedpointMatrix);
    }
};
