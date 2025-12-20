const constants = @import("../constants.zig");

const libdragon = @import("../libdragon/libdragon.zig");
const rspq = @import("../libdragon/rspq.zig");
const rdpq = @import("../libdragon/rdpq.zig");
const t3d = @import("t3d.zig");
const Transform = @import("transform.zig").Transform;

pub const Model = struct {
    t3dmodel: *t3d.c.T3DModel,
    data: *libdragon.c.rspq_block_t,
    firstDraw: bool,
    matrix: [constants.FB_COUNT]Transform,
    frameIndex: u32,

    pub fn load(path: [:0]const u8) Model {
        return .{
            .data = undefined,
            .firstDraw = false,
            .t3dmodel = t3d.c.t3d_model_load(path),
            .matrix = [_]Transform{ Transform.init() } ** constants.FB_COUNT,
            .frameIndex = 0,
        };
    }

    pub fn transform(self: *Model,
        scale: [3]f32,
        rotation: [3]f32,
        translation: [3]f32
    ) void {
        self.matrix[self.frameIndex].setup(scale, rotation, translation);
    }

    pub fn draw(self: *Model) void {
        self.matrix[self.frameIndex].push();

        if (self.firstDraw == false) {
            rspq.block_begin();
                t3d.c.t3d_model_draw(self.t3dmodel);
                t3d.matrix_pop(1);
            self.data = rspq.block_end();
            self.firstDraw = true;
        }

        rspq.block_run(self.data);

        self.frameIndex += 1;
        self.frameIndex = @mod(self.frameIndex, constants.FB_COUNT);
    }
};

