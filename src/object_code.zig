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

pub fn gear_init(o: *Object) Result {
    o.dataF[0] = 0.02;

    return .Ok;
}

pub fn gear_update(o: *Object) Result {
    const pad = contpad.getPad(1);

    if (pad.held.a) {
        o.dataF[0] += 0.001;
    }
    if (pad.held.b) {
        o.dataF[0] -= 0.001;
    }

    if (pad.pressed.z) {
        return .Warp;
    }

    o.rot[2] -= o.dataF[0];

    o.rot[1] -= 0.004;
    o.rot[0] = 0;
    o.scale = .{
        0.1,
        0.1,
        0.1
    };

    return .Ok;
}
