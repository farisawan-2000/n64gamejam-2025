const Object = @import("object.zig").Object;
const contpad = @import("contpad.zig");

pub fn default_init(o: *Object) void {
    _ = o;
}

pub fn default_update(o: *Object) void {
    _ = o;
}

pub fn gear_init(o: *Object) void {
    o.dataF[0] = 0.02;
}

pub fn gear_update(o: *Object) void {
    const pad = contpad.getPad(1);
    if (pad.held.a) {
        o.dataF[0] += 0.001;
    }
    if (pad.held.b) {
        o.dataF[0] -= 0.001;
    }

    o.rot[2] -= o.dataF[0];

    o.rot[1] -= 0.004;
    o.rot[0] = 0;
    o.scale = .{
        0.1,
        0.1,
        0.1
    };
}
