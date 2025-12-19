const t3d = @import("t3d.zig");



pub const Transform = struct {
    scale:       [3]f32,
    rotation:    [3]f32,
    translation: [3]f32,

    // export to fixed point
    fn export_t3d_mat4_fixedpoint(self: *const Transform) t3d.c.T3DMat4FP {
        var ret: t3d.c.T3DMat4FP = undefined;

        t3d.c.t3d_mat4fp_from_srt_euler(&ret, &self.scale, &self.rotation, &self.translation);

        return ret;
    }

    pub fn setup(self: *Transform, scale: [3]f32, rotation: [3]f32, translation: [3]f32) void {
        self.scale = scale;
        self.rotation = rotation;
        self.translation = translation;
    }

    pub fn push(self: *const Transform) void {
        var exported_matrix = self.export_t3d_mat4_fixedpoint();
        t3d.c.t3d_matrix_push(&exported_matrix);
    }
};
