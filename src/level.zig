const std = @import("std");
const Allocator = std.mem.Allocator;

const Camera = @import("camera.zig").Camera;
const Warp = @import("warp.zig").Warp;
const Model = @import("tiny3d/model.zig").Model;
const LevelAllocator = @import("allocators/level_allocator.zig").LevelAllocator;
const object = @import("object.zig");

const math = @import("math.zig");

const objcode = @import("object_code.zig");
const Object = object.Object;

const tiny3d = @import("tiny3d/t3d.zig");
const Screen = @import("tiny3d/screen.zig").Screen;
const Vec3 = @import("tiny3d/vec3.zig").Vec3;

const io = @import("n64_io.zig");
const File = io.File;

const libdragon = @import("libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

const log = @import("logging.zig");

const MAX_OBJS = 64;

pub const LevelType = enum(i32) {
    @"Splash Screen",
    @"2D Scene",
    @"3D Scene",
};

const LevelCommand = enum(i32) {
    None,
    LevelModel,
    CameraInit,
    CollisionMap,
    Object,
    Warp,
};

const curLevelCommand = .None;

const MAX_OBJECTS = 256;

var currentLevel: *Level = undefined;

fn token_to_enum(token: [:0]const u8) LevelCommand {
    if (std.mem.eql(u8, token, "level")) {
        return .LevelModel;
    }
    else if (std.mem.eql(u8, token, "camera")) {
        return .CameraInit;
    }
    else if (std.mem.eql(u8, token, "object")) {
        return .Object;
    }
    else if (std.mem.eql(u8, token, "warp")) {
        return .Warp;
    }
    else {
        return .None;
    }
}

pub fn load_new_level(path: [:0]u8) !void {
    const allocator = std.heap.raw_c_allocator;

    currentLevel = try allocator.create(Level);
    currentLevel.* = try Level.init(path);
}

pub fn handle_warp(warp_id: u32) void {
    const allocator = std.heap.raw_c_allocator;

    log.log("DESTROY LEVEL!\n");
    log.logU32(@intFromPtr(currentLevel));

    var path_local: [32:0]u8 = undefined;
    @memcpy(&path_local, &currentLevel.warps.items[warp_id].level);

    currentLevel.destroy(allocator);

    load_new_level(&path_local) catch unreachable;
}

pub fn nearestObjWithBehavior(self: *Object, bhv: object.ObjBehavior) ?*Object {
    var closest_dist: f32 = 99999999.0;
    var ret: ?*Object = null;

    for (currentLevel.objects.items) |*obj| {
        if (obj == self) {
            continue;
        }
        if (obj.behavior != bhv) {
            continue;
        }

        const gotDist = math.distance3(self.pos, obj.pos);
        if (gotDist < closest_dist) {
            ret = obj;
            closest_dist = gotDist;
        }
    }

    return ret;
}

pub fn getCurrentLevel() *Level {
    return currentLevel;
}

pub fn update() object.Result {
    return currentLevel.tick();
}

pub fn draw() void {
    currentLevel.draw();
}

pub fn getCamera() *Camera {
    return &currentLevel.camera;
}

pub const Level = struct {
    _arena: std.heap.ArenaAllocator,
    mesh: Model,
    objects: std.ArrayList(Object),
    warps: std.ArrayList(Warp),
    camera: Camera,
    screen: Screen,
    initialized: bool,

    fn parseLevel(self: *Level, path: [:0]u8) !void {
        // Keep everything we alloc to read this level file in one place
        var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
        defer _ = arena.reset(.free_all);

        const lvFile = File.open(path);
        defer lvFile.close();

        const a_alloc = arena.allocator();

        while (lvFile.readline()) |line| {
            log.logFmt("Line: {s}\n", .{line.to_buf()});
            // Tokenize the line using spaces as the delimiter
            var tokenizer = std.mem.tokenizeAny(u8, line.to_buf(), " ");
            var tokens = try std.ArrayList([:0]const u8).initCapacity(a_alloc, 32);

            while (tokenizer.next()) |tok| {
                const zerostr = try a_alloc.dupeZ(u8, tok);
                try tokens.append(a_alloc, zerostr);
            }

            tokenLoop: for (0.., tokens.items) |i, token| {
                const token_as_enum = token_to_enum(token);
                switch (token_as_enum) {
                    .LevelModel => {
                        self.mesh = Model.load(tokens.items[i + 1]);
                    },

                    .CameraInit => {
                        self.camera.posTarget = .{
                            try std.fmt.parseFloat(f32, tokens.items[i + 2]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 3]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 4]),
                        };
                        self.camera.lookTarget = .{
                            try std.fmt.parseFloat(f32, tokens.items[i + 6]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 7]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 8]),
                        };

                        self.camera.pos = self.camera.posTarget;
                        self.camera.look = self.camera.lookTarget;
                    },

                    .Object => {
                        try self.objects.append(std.heap.c_allocator, Object.init(
                            objcode.default_init, objcode.default_update,
                            tokens.items[i + 1], tokens.items[i + 15],

                            // pos
                            .{
                                try std.fmt.parseFloat(f32, tokens.items[i + 3]),
                                try std.fmt.parseFloat(f32, tokens.items[i + 4]),
                                try std.fmt.parseFloat(f32, tokens.items[i + 5]),
                            },

                            // rotation
                            .{
                                try std.fmt.parseFloat(f32, tokens.items[i + 7]),
                                try std.fmt.parseFloat(f32, tokens.items[i + 8]),
                                try std.fmt.parseFloat(f32, tokens.items[i + 9]),
                            },
                            // param
                            try std.fmt.parseInt(u32, tokens.items[i + 17], 10),
                        ));
                    },

                    .Warp => {
                        log.log("WARPP!\n");
                        try self.warps.append(std.heap.c_allocator, Warp.init(
                            try std.fmt.parseInt(u32, tokens.items[i + 1], 10),
                            tokens.items[i + 2],
                        ));
                    },

                    else => {
                        continue :tokenLoop;
                    }
                }
            }
        }
    }

    pub fn init(path: [:0]u8) !Level {
        var lv: Level = undefined;

        lv._arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);

        const allocator = lv._arena.allocator();

        lv.mesh = undefined;
        lv.objects = try std.ArrayList(Object).initCapacity(allocator, 32);
        lv.warps = try std.ArrayList(Warp).initCapacity(allocator, 32);
        lv.camera = Camera.init(.{0, 0, 0}, .{0, 0, 0});
        lv.screen = Screen.make(.{
            100, 80, 80, 0xFF
        });
        lv.initialized = false;

        try lv.parseLevel(path);

        lv.initialized = true;

        return lv;
    }

    pub fn tick(self: *Level) object.Result {
        var ret: object.Result = .Ok;

        const dt = libdragon.display.get_delta_time();

        for (self.objects.items) |*obj| {
            obj.deltaTime = dt;
            const result = obj.update();

            switch (result) {
                .Ok => continue,
                .SetCameraFocus => |focus| {
                    self.camera.lookTarget = focus;
                },
                else => ret = result,
            }
        }

        return ret;
    }

    pub fn draw(self: *Level) void {
        const ambientLightColor:     [4]u8 = .{80, 80, 100, 0xFF};
        const directionalLightColor: [4]u8 = .{0xEE, 0xAA, 0xAA, 0xFF};

        const lightDirVec: Vec3 = .{
            .xyz = .{-1, 1, 1}
        };

        lightDirVec.normalize();

        if (self.initialized) {
            tiny3d.frame_start();
            self.camera.update();

            self.screen.clear();
            self.screen.clear_depth();

            tiny3d.light_set_ambient(ambientLightColor);
            tiny3d.light_set_directional(0, directionalLightColor, lightDirVec);
            tiny3d.light_set_count(1);

            self.mesh.draw();

            for (self.objects.items) |*obj| {
                obj.draw();
            }
        }
    }

    pub fn destroy(self: *Level, alloc: Allocator) void {
        for (currentLevel.objects.items) |obj| {
            obj.model.destroy();
        }
        self._arena.deinit();
        alloc.destroy(self);
    }
};
