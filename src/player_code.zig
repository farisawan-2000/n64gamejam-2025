const constants = @import("constants.zig");
const object = @import("object.zig");
const level = @import("level.zig");
const contpad = @import("contpad.zig");
const log = @import("logging.zig");
const math = @import("math.zig");

const Object = object.Object;
const Result = object.Result;

// DATAF LAYOUT
pub const DataFLayout = enum(u32) {
    Yaw = 0,
};

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

    if (pad.stick_y < constants.DEADZONE and pad.stick_x < constants.DEADZONE) {
        self.dataF[@intFromEnum(DataFLayout.Yaw)] = 0;
    } else {    
        self.dataF[@intFromEnum(DataFLayout.Yaw)] = math.atan2(
            -@as(f32, @floatFromInt(pad.stick_y)),
             @as(f32, @floatFromInt(pad.stick_x))
        ) + math.deg_to_rad(level.getCamera().yaw);

        math.radian_clamp(&self.dataF[@intFromEnum(DataFLayout.Yaw)]);

        self.pos[0] += math.sin(self.dataF[@intFromEnum(DataFLayout.Yaw)]);
        self.pos[2] += math.cos(self.dataF[@intFromEnum(DataFLayout.Yaw)]);
    }

    if (self.param == 1) {

        log.logFmt("YAW: {d}\n", .{self.dataF[@intFromEnum(DataFLayout.Yaw)]});

        const nearestPly: *Object = level.nearestObjWithBehavior(self, .@"Player Fighter").?;

        return .{.SetCameraFocus = math.between3(
            self.pos,
            nearestPly.pos
        )};
    } else {
        return .Ok;
    }
}

