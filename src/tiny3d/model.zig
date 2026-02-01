const constants = @import("../constants.zig");

const libdragon = @import("../libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

const t3d = @import("t3d.zig");
const Transform = @import("transform.zig").Transform;

const log = @import("../logging.zig");

pub const Model = struct {
    t3dmodel: ?*t3d.c.T3DModel,
    data: *libdragon.c.rspq_block_t,
    firstDraw: bool,
    transform: [constants.FB_COUNT]Transform,
    frameIndex: u32,

    pub fn load(path: [:0]const u8) Model {
        return .{
            .data = undefined,
            .firstDraw = false,
            .t3dmodel = t3d.c.t3d_model_load(path),
            .transform = [_]Transform{ Transform.init() } ** constants.FB_COUNT,
            .frameIndex = 0,
        };
    }

    pub fn scale(self: *Model, newScale: f32) void {
        self.transform[self.frameIndex].scale = [_]f32{ newScale } ** 3;
    }

    pub fn scaleXYZ(self: *Model, newScale: [3]f32) void {
        self.transform[self.frameIndex].scale = newScale;
    }

    pub fn rotate(self: *Model, rotation_xyz: [3]f32) void {
        self.transform[self.frameIndex].rotation = rotation_xyz;
    }

    pub fn move(self: *Model, move_xyz: [3]f32) void {
        self.transform[self.frameIndex].translation = move_xyz;
    }

    pub fn transformSRT(self: *Model,
        newScale: [3]f32,
        rotation: [3]f32,
        translation: [3]f32
    ) void {
        self.transform[self.frameIndex].setup(newScale, rotation, translation);
    }

    pub fn draw(self: *Model) void {
        self.transform[self.frameIndex].push();

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

    pub fn destroy(self: *Model) void {
        self.firstDraw = false;
        t3d.free_model(self.t3dmodel);
        rspq.block_free(self.data);
        self.data = undefined;
    }
};

