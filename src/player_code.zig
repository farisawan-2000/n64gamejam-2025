const object = @import("object.zig");
const level = @import("level.zig");
const contpad = @import("contpad.zig");
const log = @import("logging.zig");


const Object = object.Object;
const Result = object.Result;


pub fn player_init(self: *Object) Result {
    _ = self;
    return .Ok;
}

pub fn player_update(self: *Object) Result {
    const pad = contpad.getPad(@bitCast(self.param));

    if (pad.held.a) {
        self.pos[1] += 100.0 * self.deltaTime;
    }

    if (pad.held.b) {
        self.pos[1] -= 100.0 * self.deltaTime;
    }

    return .{.SetCameraFocus = self.pos};
}

