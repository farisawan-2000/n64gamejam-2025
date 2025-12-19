const t3d = @import("t3d.zig");

pub const Model = struct {
    t3dmodel: *t3d.c.T3DModel,

    pub fn load(path: [:0]const u8) Model {
        return .{
            .t3dmodel = t3d.c.t3d_model_load(path),
        };
    }

    pub fn draw(self: *const Model) void {
        t3d.c.t3d_model_draw(self.t3dmodel);
    }
};

