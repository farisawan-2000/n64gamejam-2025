const constants = @import("constants.zig");
const object = @import("object.zig");
const level = @import("level.zig");
const contpad = @import("contpad.zig");
const log = @import("logging.zig");
const math = @import("math.zig");

const Object = object.Object;
const Result = object.Result;

const State = enum(u32) {
    Idle,
    Walk,
    Jump,
    DoubleJump,
    Attack,
    AttackAir,
    Win,
    Lose,
};

// DATAF LAYOUT
pub const DataFLayout = enum(u32) {
    Yaw = 0,
    Timer = 1,
};

pub const DataLayout = enum(u32) {
    State = 0,
    NextState = 1,
};

fn set_state(self: *Object, state: State) void {
    self.set_fieldE(DataLayout, .State, State, state);
}

fn set_next_state(self: *Object, state: State) void {
    self.set_fieldE(DataLayout, .NextState, State, state);
}

pub fn player_idle(self: *Object) void {
    const pad = contpad.getPad(@intCast(self.param));

    if (pad.pressed.a) {
        self.vel[1] = 50;
        set_next_state(self, .Jump);
    }

    if (pad.pressed.b) {
        set_next_state(self, .Attack);
    }
}

pub fn player_jump(self: *Object) void {
    const pad = contpad.getPad(@intCast(self.param));

    if (pad.pressed.a) {
        self.vel[1] = 50;
        set_next_state(self, .DoubleJump);
    }

    if (pad.pressed.b) {
        set_next_state(self, .AttackAir);
    }

    if (self.pos[1] == 0.0) {
        set_next_state(self, .Idle);
    }
}

pub fn player_djump(self: *Object) void {
    const pad = contpad.getPad(@intCast(self.param));

    if (self.pos[1] == 0.0) {
        set_next_state(self, .Idle);
    }

    if (pad.pressed.b) {
        set_next_state(self, .AttackAir);
    }
}

pub fn player_attack(self: *Object) void {
    self.dataF[@intFromEnum(DataFLayout.Yaw)] += 0.01;
    math.radian_clamp(&self.dataF[@intFromEnum(DataFLayout.Yaw)]);

    if (self.timer > 60.0) {
        set_next_state(self, .Idle);
    }
}

pub fn player_state_proc(self: *Object) void {
    switch (self.get_fieldE(DataLayout, .State, State)) {
        .Idle => player_idle(self),
        .Jump => player_jump(self),
        .DoubleJump => player_djump(self),
        .Attack => player_attack(self),
        else => unreachable,
    }

    if (self.param == 1) {
        log.logU32(self.get_field(DataLayout, .NextState));
    }

    if (self.get_field(DataLayout, .NextState) != self.get_field(DataLayout, .State)) {
        self.set_field(DataLayout, .State, self.get_field(DataLayout, .NextState));
        self.timer = 0.0;
    }
}

pub fn player_init(self: *Object) Result {
    self.set_fieldE(DataLayout, .State, State, .Idle);
    self.set_fieldE(DataLayout, .NextState, State, .Idle);
    return .Ok;
}

pub fn player_update(self: *Object) Result {
    const pad = contpad.getPad(@intCast(self.param));

    var stickmag = math.mag2(i32, pad.stick_x, pad.stick_y);

    if (stickmag > 64) {
        stickmag = 64;
    }

    if (stickmag < constants.DEADZONE) {
        stickmag = 0;
    }

    if (stickmag > 0) {
        self.dataF[@intFromEnum(DataFLayout.Yaw)] = math.atan2(
             @as(f32, @floatFromInt(pad.stick_y)),
             @as(f32, @floatFromInt(pad.stick_x))
        ) + math.deg_to_rad(level.getCamera().yaw) + (math.pi / 2.0);

        math.radian_clamp(&self.dataF[@intFromEnum(DataFLayout.Yaw)]);
    }
    self.vel[0] = stickmag * math.sin(self.dataF[@intFromEnum(DataFLayout.Yaw)]);
    self.vel[2] = stickmag * math.cos(self.dataF[@intFromEnum(DataFLayout.Yaw)]);

    player_state_proc(self);

    self.pos[0] += self.vel[0];
    self.pos[1] += self.vel[1];
    self.pos[2] += self.vel[2];

    self.vel[1] += constants.GRAVITY;

    if (self.pos[1] < 0.0) {
        self.pos[1] = 0.0;
    }

    if (self.pos[0] < -constants.LEVEL_BOUND) {
        self.pos[0] = -constants.LEVEL_BOUND;
    }
    if (self.pos[0] > constants.LEVEL_BOUND) {
        self.pos[0] = constants.LEVEL_BOUND;
    }
    if (self.pos[2] < -constants.LEVEL_BOUND) {
        self.pos[2] = -constants.LEVEL_BOUND;
    }
    if (self.pos[2] > constants.LEVEL_BOUND) {
        self.pos[2] = constants.LEVEL_BOUND;
    }

    if (self.param == 1) {
        const nearestPly: *Object = level.nearestObjWithBehavior(self, .@"Player Fighter").?;

        return .{.SetCameraFocus = math.between3(
            self.pos,
            nearestPly.pos
        )};
    } else {
        return .Ok;
    }
}

