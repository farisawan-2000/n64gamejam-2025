const std = @import("std");
const Allocator = std.mem.Allocator;

const Object = @import("object.zig").Object;
const Model = @import("tiny3d/model.zig").Model;
const LevelAllocator = @import("allocators/level_allocator.zig").LevelAllocator;

const io = @import("n64_io.zig");
const File = io.File;

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

    fn parseLevel(self: *Level, path: [:0]u8) !void {
        var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);

        const lvFile = File.open(path);
        defer lvFile.close();

        const a_alloc = arena.allocator();
        defer _ = arena.reset(.free_all);

        while (lvFile.readline()) |line| {
            // Tokenize the line using spaces as the delimiter
            var tokenizer = std.mem.tokenizeAny(u8, line, " ");
            var tokens = try std.ArrayList([:0]const u8).initCapacity(a_alloc, 32);

            while (tokenizer.next()) |tok| {
                const zerostr = try a_alloc.dupeZ(u8, tok);
                log.log(zerostr);
                try tokens.append(a_alloc, zerostr);
            }

            tokenLoop: for (0.., tokens.items) |i, token| {
                const token_as_enum = token_to_enum(token);
                switch (token_as_enum) {
                    .LevelModel => {
                        self.mesh = Model.load(tokens.items[i + 1]);
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
        };

        // lv.arena.initAllocator();

        try lv.parseLevel(path);

        return lv;
    }

    pub fn tick(self: *Level) void {
        for (self.objects) |*obj| {
            obj.update();
        }
    }

    pub fn draw(self: *Level) void {
        self.mesh.draw();

        for (self.objects) |*obj| {
            obj.draw();
        }
    }

    pub fn destroy() void {
        // 
    }
};
