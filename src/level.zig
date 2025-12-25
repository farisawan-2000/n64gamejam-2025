const std = @import("std");
const Allocator = std.mem.Allocator;

const Object = @import("object.zig").Object;
const LevelAllocator = @import("allocators/level_allocator.zig").LevelAllocator;

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

fn token_to_enum(token: []const u8) LevelCommand {
    if (std.mem.eql(u8, token, "level")) {
        return .LevelModel;
    }
    else if (std.mem.eql(u8, token, "camera")) {
        return .CameraInit;
    }
}

fn parseLevel(arena: Allocator, path: [:0]u8) ?*[]Object {
    const lvFile = std.fs.cwd().openFile(path);
    defer lvFile.close();

    while(
        lvFile.reader().readUntilDelimiterOrEofAlloc(
            arena, '\n', std.math.maxInt(usize)
        )
    ) |line| {
        // Tokenize the line using spaces as the delimiter
        const tokenizer = std.mem.tokenizeAny(u8, line, " ");
        var tokens = std.ArrayList([]const u8).init(arena);

        // defer in reverse order
        defer tokens.deinit();
        defer arena.free(line);

        for (tokenizer) |tok| {
            tokens.append(tok);
        }

        tokenLoop: for (0.., tokens) |i, token| {
            _ = i;
            const token_as_enum = token_to_enum(token);
            switch (token_as_enum) {
                .LevelModel => {
                    
                },

                _ => {
                    continue :tokenLoop;
                }
            }
        }
    }

    return null;
}

pub const Level = struct {
    arena: LevelAllocator,
    objects: ?*[]Object,

    pub fn init(path: [:0]u8) Level {
        const lv = .{
            .arena = LevelAllocator.init(),
            .objects = null,
        };

        lv.arena.initAllocator();

        lv.objects = parseLevel(path);

        return lv;
    }

    pub fn tick(self: *Level) void {
        const objStart = self.objects[0];
        var objPtr = objStart.next;

        while (objPtr != objStart) : (objPtr = objPtr.next) {
            objPtr.update();
        }
    }

    pub fn destroy() void {
        // 
    }
};
