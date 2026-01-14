const constants = @import("constants.zig");
const std = @import("std");

const Model = @import("tiny3d/model.zig").Model;
const objcode = @import("object_code.zig");
const log = @import("logging.zig");

pub const ObjBehavior = enum {
    @"Static Object",
    @"Rotating Gear",
};

pub const Result = union(enum) {
    Ok,
    Warp: u32,
};

pub fn token_to_behavior(token: [:0]const u8) ObjBehavior {
    if (std.mem.eql(u8, token, "static")) {
        return .@"Static Object";
    }
    else if (std.mem.eql(u8, token, "gear")) {
        return .@"Rotating Gear";
    }
    else {
        return .@"Static Object";
    }
}

pub fn set_obj_code(o: *Object) void {
    switch (o.behavior) {
        .@"Static Object" => {
            o.initFunc = objcode.default_init;
            o.updateFunc = objcode.default_update;
        },

        .@"Rotating Gear" => {
            o.initFunc = objcode.gear_init;
            o.updateFunc = objcode.gear_update;
        },
    }
}

pub fn link(a: *Object, b: *Object) void {
    a.next = b;
    b.prev = a;
}

pub const Object = struct {
    initFunc: *const fn(o: *Object) Result,
    updateFunc: *const fn(o: *Object) Result,
    model: Model,
    behavior: ObjBehavior,

    // fields:
    pos: [3]f32,
    rot: [3]f32,
    scale: [3]f32,

    // User data:
    data: [8]u32,
    dataF: [8]f32,

    pub fn init(
        initFPtr: *const fn(o: *Object) Result,
        updateFPtr: *const fn(o: *Object) Result,
        modelPath: [:0]const u8,
        bhvString: [:0]const u8,
        position: [3]f32,
        rotation: [3]f32,
    ) Object {
        var obj = Object {
            .initFunc = initFPtr,
            .updateFunc = updateFPtr,
            .model = Model.load(modelPath),
            .behavior = token_to_behavior(bhvString),

            .pos = position,
            .rot = rotation,
            .scale = .{1, 1, 1},

            .data = [_]u32{ 0 } ** 8,
            .dataF = [_]f32{ 0 } ** 8,
        };

        obj.model.frameIndex = 0;

        set_obj_code(&obj);

        return obj;
    }

    pub fn update(self: *Object) Result {
        const result = self.updateFunc(self);

        self.model.scaleXYZ(self.scale);
        self.model.rotate(self.rot);
        self.model.move(self.pos);

        return result;
    }

    pub fn draw(self: *Object) void {
        self.model.draw();
    }
};
