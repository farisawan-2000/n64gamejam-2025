
const Model = @import("tiny3d/model.zig").Model;

pub const Object = struct {
    initFunc: *const fn(o: *Object) void,
    updateFunc: *const fn(o: *Object) void,
    model: Model,

    // fields:
    pos: [3]f32,
    rot: [3]f32,
    scale: [3]f32,


    pub fn init(
        initFPtr: *const fn(o: *Object) void,
        updateFPtr: *const fn(o: *Object) void,
        modelPath: [:0]const u8
    ) Object {
        return .{
            .initFunc = initFPtr,
            .updateFunc = updateFPtr,
            .model = Model.load(modelPath),

            .pos = .{0, 0, 0},
            .rot = .{0, 0, 0},
            .scale = .{1, 1, 1},
        };
    }

    pub fn update(self: *Object) void {
        self.updateFunc(self);
        self.model.scaleXYZ(self.scale);
        self.model.rotate(self.rot);
        self.model.move(self.pos);
    }

    pub fn draw(self: *Object) void {
        self.model.draw();
    }
};
