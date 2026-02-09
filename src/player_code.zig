const std = @import("std");
const constants = @import("constants.zig");
const object = @import("object.zig");
const level = @import("level.zig");
const contpad = @import("contpad.zig");
const log = @import("logging.zig");
const math = @import("math.zig");

const Object = object.Object;
const Result = object.Result;

const State = enum(u32) {
    ReadyGoCountdown,
    Idle,
    Walk,
    Jump,
    DoubleJump,
    Attack,
    AttackAir,
    DownAirInit,
    DownAirAttack,
    Damaged,
    Win,
    Lose,
};

const ATTACK_TIME = 0.25;

// DATAF LAYOUT
pub const PlayerData = struct {
    yaw: f32,
    timer: f32,
    baseYaw: f32,
    damage: f32,

    state: State,
    nextState: State,
    affectedByGravity: bool,
    canMove: bool,
};

fn set_state(self: *Object, newstate: State) void {
    self.get_data(PlayerData).state = newstate;
}

fn set_next_state(self: *Object, newstate: State) void {
    self.get_data(PlayerData).nextState = newstate;
}

pub fn player_idle(self: *Object) void {
    const pad = contpad.getPad(@intCast(self.param));

    self.get_data(PlayerData).affectedByGravity = true;
    self.get_data(PlayerData).canMove = true;

    self.get_data(PlayerData).baseYaw = 0.0;

    if (pad.pressed.a) {
        self.vel[1] = 50;
        set_next_state(self, .Jump);
    }

    if (pad.pressed.b) {
        set_next_state(self, .Attack);
    }
}

pub fn player_dair_init(self: *Object) void {
    self.get_data(PlayerData).affectedByGravity = false;
    self.get_data(PlayerData).canMove = false;
    self.vel[1] = 0.0;
    self.rot[0] += 0.05;

    if (self.timer > 0.5) {
        set_next_state(self, .DownAirAttack);
    }
}

pub fn player_dair_attack(self: *Object) void {
    self.get_data(PlayerData).affectedByGravity = true;

    self.rot[0] = math.pi;

    if (self.pos[1] == 0.0) {
        set_next_state(self, .Idle);
        level.damage_stage(10.0);
        self.get_data(PlayerData).canMove = true;
        self.rot[0] = 0;

        if (level.get_stage_damage() >= 100) {
            const nearestPly: *Object = level.nearestObjWithBehavior(self, .@"Player Fighter").?;

            nearestPly.get_data(PlayerData).damage += 50.0;
            set_next_state(nearestPly, .Damaged);
            nearestPly.vel = .{90.0, 50.0, 50.0};

            if (self.get_data(PlayerData).damage >= 100.0) {
                set_next_state(self, .Lose);
                self.change_model(if (self.param == 1) "rom:/player1_4.t3dm" else "rom:/player2_4.t3dm");
            } else if (self.get_data(PlayerData).damage >= 70.0) {
                self.change_model(if (self.param == 1) "rom:/player1_3.t3dm" else "rom:/player2_3.t3dm");
            } else if (self.get_data(PlayerData).damage >= 30.0) {
                self.change_model(if (self.param == 1) "rom:/player1_2.t3dm" else "rom:/player2_2.t3dm");
            }

            level.reset_stage_damage();
        }
    }
}

pub fn player_jump(self: *Object) void {
    const pad = contpad.getPad(@intCast(self.param));

    self.get_data(PlayerData).baseYaw = 0.0;

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

    if (pad.pressed.z) {
        set_next_state(self, .DownAirInit);
    }
}

pub fn player_djump(self: *Object) void {
    const pad = contpad.getPad(@intCast(self.param));

    self.get_data(PlayerData).baseYaw = 0.0;

    if (self.pos[1] == 0.0) {
        set_next_state(self, .Idle);
    }

    if (pad.pressed.b) {
        set_next_state(self, .AttackAir);
    }

    if (pad.pressed.z) {
        set_next_state(self, .DownAirInit);
    }
}

pub fn player_attack(self: *Object) void {
    self.get_data(PlayerData).baseYaw = 0.5;
    math.radian_clamp(&self.get_data(PlayerData).baseYaw);

    if (self.timer > ATTACK_TIME) {
        set_next_state(self, .Idle);
    }
}

pub fn player_attack_air(self: *Object) void {
    self.get_data(PlayerData).baseYaw = 0.5;
    math.radian_clamp(&self.get_data(PlayerData).baseYaw);

    if (self.timer > ATTACK_TIME) {
        set_next_state(self, .Jump);
    }
}

pub fn player_damaged(self: *Object) void {
    self.get_data(PlayerData).affectedByGravity = true;
    self.get_data(PlayerData).canMove = true;
    self.rot[0] = 0;
    if (self.pos[1] == 0.0) {
        set_next_state(self, .Idle);
    }
}

pub fn player_lose(self: *Object) void {
    self.vel = .{0, 0, 0};
}

pub fn player_stop(self: *Object) void {
    self.get_data(PlayerData).canMove = false;

    if (self.timer > 1.5) {
        self.get_data(PlayerData).canMove = true;
        set_next_state(self, .Idle);
    }
}







pub fn player_state_proc(self: *Object) void {
    switch (self.get_data(PlayerData).state) {
        .ReadyGoCountdown => player_stop(self),
        .Idle => player_idle(self),
        .Jump => player_jump(self),
        .DoubleJump => player_djump(self),
        .Attack => player_attack(self),
        .AttackAir => player_attack_air(self),
        .DownAirInit => player_dair_init(self),
        .DownAirAttack => player_dair_attack(self),
        .Damaged => player_damaged(self),
        .Lose => player_lose(self),
        else => unreachable,
    }

    const nearestPly: *Object = level.nearestObjWithBehavior(self, .@"Player Fighter").?;

    if (math.dist3(self.pos, nearestPly.pos) < 200.0) {
        if ((nearestPly.get_data(PlayerData).state == .AttackAir)
         or (nearestPly.get_data(PlayerData).state == .Attack)) {
            if (self.get_data(PlayerData).state != .Damaged) {
                // only get hit once per damage cycle
                self.get_data(PlayerData).damage += 10.0;
                set_next_state(self, .Damaged);
                self.vel = math.pushaway(self.pos, nearestPly.pos, 1.0);
                self.vel[1] = 50.0;
                if (self.get_data(PlayerData).damage >= 100.0) {
                    set_next_state(self, .Lose);
                    self.change_model(if (self.param == 1) "rom:/player1_4.t3dm" else "rom:/player2_4.t3dm");
                } else if (self.get_data(PlayerData).damage >= 70.0) {
                    self.change_model(if (self.param == 1) "rom:/player1_3.t3dm" else "rom:/player2_3.t3dm");
                } else if (self.get_data(PlayerData).damage >= 30.0) {
                    self.change_model(if (self.param == 1) "rom:/player1_2.t3dm" else "rom:/player2_2.t3dm");
                }
            }
        }
    }

    if (self.get_data(PlayerData).nextState != self.get_data(PlayerData).state) {
        self.get_data(PlayerData).state = self.get_data(PlayerData).nextState;
        self.timer = 0.0;
    }
}





pub fn player_init(self: *Object, allocator: std.mem.Allocator) Result {
    self.data = allocator.create(PlayerData) catch unreachable;
    self.get_data(PlayerData).affectedByGravity = true;
    self.get_data(PlayerData).canMove = false;
    self.get_data(PlayerData).baseYaw = 0.0;
    self.get_data(PlayerData).damage = 0.0;
    self.get_data(PlayerData).state = .Idle;
    self.get_data(PlayerData).nextState = .Idle;
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

    if (self.get_data(PlayerData).canMove == false) {
        stickmag = 0;
    }


    if (stickmag > 0) {
        self.get_data(PlayerData).yaw = math.atan2(
             -@as(f32, @floatFromInt(pad.stick_y)),
             @as(f32, @floatFromInt(pad.stick_x))
        ) + math.deg_to_rad(level.getCamera().yaw) + (math.pi / 2.0);

        math.radian_clamp(&self.get_data(PlayerData).yaw);
    }

    if (self.get_data(PlayerData).state != .Damaged) {
        self.vel[0] = stickmag * math.sin(self.get_data(PlayerData).yaw);
        self.vel[2] = stickmag * -math.cos(self.get_data(PlayerData).yaw);
    }

    player_state_proc(self);

    self.get_data(PlayerData).yaw += self.get_data(PlayerData).baseYaw;
    math.radian_clamp(&self.get_data(PlayerData).yaw);

    self.pos[0] += self.vel[0];
    self.pos[1] += self.vel[1];
    self.pos[2] += self.vel[2];

    self.rot[1] = self.get_data(PlayerData).yaw;

    if (self.get_data(PlayerData).affectedByGravity == true) {
        self.vel[1] += constants.GRAVITY;
    }

    if (self.pos[1] < 0.0) {
        self.pos[1] = 0.0;
    }

    if (self.pos[0] < -constants.LEVEL_BOUND) {
        self.pos[0] = -constants.LEVEL_BOUND;
        self.vel[0] *= -1;
    }
    if (self.pos[0] > constants.LEVEL_BOUND) {
        self.pos[0] = constants.LEVEL_BOUND;
        self.vel[0] *= -1;
    }
    if (self.pos[2] < -constants.LEVEL_BOUND) {
        self.pos[2] = -constants.LEVEL_BOUND;
        self.vel[2] *= -1;
    }
    if (self.pos[2] > constants.LEVEL_BOUND) {
        self.pos[2] = constants.LEVEL_BOUND;
        self.vel[2] *= -1;
    }

    const nearestPly: *Object = level.nearestObjWithBehavior(self, .@"Player Fighter").?;

    if ((self.timer >= 1.0) and (self.get_data(PlayerData).state == .Lose)) {
        return .{.Warp = if (self.param == 1) 5 else 4};
    }

    if (self.param == 1) {
        // level.getCamera().distance = 1000.0 + math.dist3(self.pos, nearestPly.pos);
        return .{.SetCameraFocus = math.between3(
            self.pos,
            nearestPly.pos
        )};
    } else {
        return .Ok;
    }
}

