const constants = @import("constants.zig");
const std = @import("std");

const Model = @import("tiny3d/model.zig").Model;
const objcode = @import("object_code.zig");
const playercode = @import("player_code.zig");
const log = @import("logging.zig");

pub const ObjBehavior = enum {
    @"Static Object",
    @"Rotating Gear",
    @"Player Fighter",
    @"Press Button To Warp",
};

pub const Result = union(enum) {
    Ok,
    Warp: u32,
    SetCameraFocus: [3]f32,
};

pub fn token_to_behavior(token: [:0]const u8) ObjBehavior {
    if (std.mem.eql(u8, token, "static")) {
        return .@"Static Object";
    }
    else if (std.mem.eql(u8, token, "gear")) {
        return .@"Rotating Gear";
    }
    else if (std.mem.eql(u8, token, "fighter")) {
        return .@"Player Fighter";
    }
    else if (std.mem.eql(u8, token, "warpbutton")) {
        return .@"Press Button To Warp";
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

        .@"Player Fighter" => {
            o.initFunc = playercode.player_init;
            o.updateFunc = playercode.player_update;
        },

        .@"Press Button To Warp" => {
            o.initFunc = objcode.default_init;
            o.updateFunc = objcode.press_button_to_warp;
        }
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

    vel: [3]f32,

    // User data:
    param: u32,
    data: [8]u32,
    dataF: [8]f32,

    // deltatime
    deltaTime: f32,

    pub fn init(
        initFPtr: *const fn(o: *Object) Result,
        updateFPtr: *const fn(o: *Object) Result,
        modelPath: [:0]const u8,
        bhvString: [:0]const u8,
        position: [3]f32,
        rotation: [3]f32,
        paramVal: u32,
    ) Object {
        var obj = Object {
            .initFunc = initFPtr,
            .updateFunc = updateFPtr,
            .model = Model.load(modelPath),
            .behavior = token_to_behavior(bhvString),

            .deltaTime = 0.0,

            .pos = position,
            .rot = rotation,
            .scale = .{1, 1, 1},

            .vel = .{0, 0, 0},

            .data = [_]u32{ 0 } ** 8,
            .dataF = [_]f32{ 0 } ** 8,
            .param = paramVal,
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
