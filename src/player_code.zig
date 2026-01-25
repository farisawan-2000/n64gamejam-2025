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
    return .{.SetCameraFocus = self.pos};
}

