const libdragon = @import("libdragon/libdragon.zig");
const log = @import("logging.zig");


pub fn tokenize() [][]u8 {

}

pub const Line = struct {
    buf: [1024]u8,
    line_end: u32,

    pub fn init() Line {
        return .{
            .buf = [_]u8 { 0 } ** 1024,
            .line_end = 0,
        };
    }

    pub fn to_buf(self: *const Line) []const u8 {
        return &self.buf;
    }
};

pub const File = struct {
    fptr: ?*libdragon.c.FILE,
    size: u32,

    pub fn open(path: [:0]const u8) File {
        var fileToReturn = File {
            .fptr = libdragon.c.fopen(path, "r"),
            .size = 0,
        };

        _ = libdragon.c.fseek(fileToReturn.fptr, 0, libdragon.c.SEEK_END);
        fileToReturn.size = @intCast(libdragon.c.ftell(fileToReturn.fptr));
        _ = libdragon.c.rewind(fileToReturn.fptr);

        return fileToReturn;
    }

    pub fn close(self: *const File) void {
        _ = libdragon.c.fclose(self.fptr);
    }

    pub fn readline(self: *const File) ?Line {
        _ = self;
        var ret: ?Line = null;

        ret = null;
        return ret;
    }
};
