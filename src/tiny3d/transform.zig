const t3d = @import("t3d.zig");

pub const Transform = struct {
    scale:       [3]f32,
    rotation:    [3]f32,
    translation: [3]f32,

    matrix: *t3d.c.T3DMat4FP,

    pub fn init() Transform {
        return .{
            .scale = .{1, 1, 1},
            .rotation = .{0, 0, 0},
            .translation = .{0, 0, 0},
            .matrix = @alignCast(
                @ptrCast(
                    t3d.c.malloc_uncached(@sizeOf(t3d.c.T3DMat4FP))
                )
            ),
        };
    }

    // export to fixed point
    fn setup_t3d_mat4_fixedpoint(self: *Transform) void {
        t3d.c.t3d_mat4fp_from_srt_euler(self.matrix, &self.scale, &self.rotation, &self.translation);
    }

    pub fn setup(self: *Transform, scale: [3]f32, rotation: [3]f32, translation: [3]f32) void {
        self.scale = scale;
        self.rotation = rotation;
        self.translation = translation;
    }

    pub fn push(self: *Transform) void {
        self.setup_t3d_mat4_fixedpoint();
        t3d.c.t3d_matrix_push(self.matrix);
    }
};
