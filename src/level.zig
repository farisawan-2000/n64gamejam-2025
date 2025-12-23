const std = @import("std");
const Allocator = std.mem.Allocator;

const Object = @import("object.zig").Object;
const LevelAllocator = @import("allocators/level_allocator.zig").LevelAllocator;

pub const LevelType = enum(i32) {
    SplashScreen,
    @"2DScene",
    @"3DScene",
};

const MAX_OBJECTS = 256;

fn parseLevel(arena: Allocator, path: [:0]u8) ?*[]Object {
    const lvFile = std.fs.cwd().openFile(path);
    defer lvFile.close();

    while(
        lvFile.reader().readUntilDelimiterOrEofAlloc(
            arena, '\n', std.math.maxInt(usize)
        )
    ) |line| {
        defer arena.free(line);
        // _ = line; // Do something with the line
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
