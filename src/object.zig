
const Model = @import("tiny3d/model.zig").Model;

pub fn link(a: *Object, b: *Object) void {
    a.next = b;
    b.prev = a;
}

pub const Object = struct {
    initFunc: *const fn(o: *Object) void,
    updateFunc: *const fn(o: *Object) void,
    model: Model,

    // fields:
    pos: [3]f32,
    rot: [3]f32,
    scale: [3]f32,

    // User data:
    data: [8]u32,
    dataF: [8]f32,


    // link list
    next: ?*Object,
    prev: ?*Object,


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

            .data = [_]u32{ 0 } ** 8,
            .dataF = [_]f32{ 0 } ** 8,

            .next = null,
            .prev = null,
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
