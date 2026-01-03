const std = @import("std");
const Allocator = std.mem.Allocator;

const Camera = @import("camera.zig").Camera;
const Object = @import("object.zig").Object;
const Model = @import("tiny3d/model.zig").Model;
const LevelAllocator = @import("allocators/level_allocator.zig").LevelAllocator;

const tiny3d = @import("tiny3d/t3d.zig");
const Screen = @import("tiny3d/screen.zig").Screen;
const Vec3 = @import("tiny3d/vec3.zig").Vec3;

const io = @import("n64_io.zig");
const File = io.File;

const libdragon = @import("libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

const log = @import("logging.zig");

pub const LevelType = enum(i32) {
    SplashScreen,
    @"2D Scene",
    @"3D Scene",
};

const LevelCommand = enum(i32) {
    None,
    LevelModel,
    CameraInit,
    CollisionMap,
    Object,
};

const curLevelCommand = .None;

const MAX_OBJECTS = 256;

fn token_to_enum(token: [:0]const u8) LevelCommand {
    if (std.mem.eql(u8, token, "level")) {
        return .LevelModel;
    }
    else if (std.mem.eql(u8, token, "camera")) {
        return .CameraInit;
    }
    else {
        return .None;
    }
}

pub const Level = struct {
    mesh: Model,
    objects: []Object,
    camera: Camera,
    screen: Screen,
    initialized: bool,

    fn parseLevel(self: *Level, path: [:0]u8) !void {
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
                        log.log("LEVEL INIT\n");
                        self.mesh = Model.load(tokens.items[i + 1]);
                    },

                    .CameraInit => {
                        log.log("CAM INIT\n");
                        log.log(tokens.items[i + 2]);
                        log.log("\n");
                        log.log(tokens.items[i + 3]);
                        log.log("\n");
                        log.log(tokens.items[i + 4]);
                        log.log("\n");

                        self.camera.pos = .{
                            try std.fmt.parseFloat(f32, tokens.items[i + 2]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 3]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 4]),
                        };
                        self.camera.rot = .{
                            try std.fmt.parseFloat(f32, tokens.items[i + 6]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 7]),
                            try std.fmt.parseFloat(f32, tokens.items[i + 8]),
                        };
                    },

                    else => {
                        continue :tokenLoop;
                    }
                }
            }
        }
    }

    pub fn init(path: [:0]u8) !Level {
        var lv: Level = .{
            // .arena = LevelAllocator.init(),
            .mesh = undefined,
            .objects = &[_]Object{},
            .camera = Camera.init(.{0, 0, 0}, .{0, 0, 0}),
            .screen = Screen.make(.{
                100, 80, 80, 0xFF
            }),
            .initialized = false,
        };

        // lv.arena.initAllocator();

        try lv.parseLevel(path);

        lv.initialized = true;

        return lv;
    }

    pub fn tick(self: *Level) void {
        for (self.objects) |*obj| {
            obj.update();
        }
    }

    pub fn draw(self: *Level) void {
        const ambientLightColor:     [4]u8 = .{80, 80, 100, 0xFF};
        const directionalLightColor: [4]u8 = .{0xEE, 0xAA, 0xAA, 0xFF};

        const lightDirVec: Vec3 = .{
            .xyz = .{-1, 1, 1}
        };

        lightDirVec.normalize();

        rdpq.attach(libdragon.c.display_get(), libdragon.c.display_get_zbuf());

        if (self.initialized) {
            tiny3d.frame_start();
            self.camera.update();

            self.screen.clear();
            self.screen.clear_depth();

            tiny3d.light_set_ambient(ambientLightColor);
            tiny3d.light_set_directional(0, directionalLightColor, lightDirVec);
            tiny3d.light_set_count(1);

            self.mesh.draw();

            for (self.objects) |*obj| {
                obj.draw();
            }
        }
        rdpq.detach_show();
    }

    pub fn destroy() void {
        // 
    }
};
