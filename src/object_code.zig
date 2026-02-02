const object = @import("object.zig");
const level = @import("level.zig");
const contpad = @import("contpad.zig");
const log = @import("logging.zig");


const Object = object.Object;
const Result = object.Result;


pub fn default_init(o: *Object) Result {
    _ = o;

    return .Ok;
}

pub fn default_update(o: *Object) Result {
    _ = o;

    return .Ok;
}

pub fn readygo_update(o: *Object) Result {
    if (o.timer > 0.75) {
        if (o.data[0] == 0) {
            o.change_model("rom:/go.t3dm");
            o.data[0] = 1;
        }
    }

    if (o.timer > 1.5) {
        if (o.data[0] == 1) {
            o.change_model("rom:/null.t3dm");
            o.data[0] = 2;
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

pub fn gear_init(o: *Object) Result {
    o.dataF[0] = 0.02;

    return .Ok;
}

pub fn gear_update(o: *Object) Result {
    const pad = contpad.getPad(1);

    if (pad.held.a) {
        o.dataF[0] += o.deltaTime;
    }
    if (pad.held.b) {
        o.dataF[0] -= o.deltaTime;
    }

    if (pad.pressed.z) {
        return .{ .Warp = 1 };
    }

    o.rot[2] -= o.dataF[0];

    o.rot[1] -= 0.004;
    o.rot[0] = 0;
    // o.scale = .{
    //     0.1,
    //     0.1,
    //     0.1
    // };

    return .Ok;
}

pub fn splash_init(o: *Object) Result {
    o.data[0] = 0;

    return .Ok;
}

pub fn splash_update(o: *Object) Result {
    o.data[0] += 1;

    if (o.data[0] > 60) {
        return .{ .Warp = 1 };
    }

    return .Ok;
}
