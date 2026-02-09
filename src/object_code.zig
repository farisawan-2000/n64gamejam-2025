const std = @import("std");

const object = @import("object.zig");
const level = @import("level.zig");
const contpad = @import("contpad.zig");
const log = @import("logging.zig");


const Object = object.Object;
const Result = object.Result;


pub fn default_init(o: *Object, allocator: std.mem.Allocator) Result {
    _ = o;
    _ = allocator;

    return .Ok;
}

pub fn default_update(o: *Object) Result {
    _ = o;

    return .Ok;
}

pub fn readygo_update(o: *Object) Result {
    if (o.timer > 0.75) {
        if (o.param == 0) {
            o.change_model("rom:/go.t3dm");
            o.param = 1;
        }
    }

    if (o.timer > 1.5) {
        if (o.param == 1) {
            o.change_model("rom:/null.t3dm");
            o.param = 2;
        }
    }

    return .Ok;
}

pub fn press_button_to_warp(o: *Object) Result {
    const pad = contpad.getPad(1);

    if (pad.pressed.a or pad.pressed.start) {
        return .{.Warp = o.param};
    } else {
        return .Ok;
    }
}

// pub fn splash_init(o: *Object) Result {
//     o.param = 0;

//     return .Ok;
// }

// pub fn splash_update(o: *Object) Result {
//     o.param += 1;

//     if (o.param > 60) {
//         return .{ .Warp = 1 };
//     }

//     return .Ok;
// }
