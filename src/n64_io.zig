const libdragon = @import("libdragon/libdragon.zig");
const log = @import("logging.zig");


pub fn tokenize() [][]u8 {

}

pub const Line = struct {
    buf: [1024]u8,
    line_end: usize,

    pub fn init(f: *const File) Line {
        var ret = Line {
            .buf = [_]u8 { 0 } ** 1024,
            .line_end = 0,
        };

        const str = libdragon.c.fgets(&ret.buf, 1024, f.fptr);
        if (str != null) {
            ret.line_end = libdragon.c.strlen(&ret.buf) - 1;
        }

        return ret;
    }

    pub fn to_buf(self: *const Line) []const u8 {
        return self.buf[0..self.line_end];
    }
};

pub const File = struct {
    fptr: ?*libdragon.c.FILE,
    size: u32,

    pub fn open(path: [:0]const u8) File {
        log.logFmt("OPENFILE {s}\n", .{path});
        var fileToReturn = File {
            .fptr = libdragon.c.fopen(path, "r"),
            .size = 0,
        };

        log.logU32(@intFromPtr(fileToReturn.fptr));

        _ = libdragon.c.fseek(fileToReturn.fptr, 0, libdragon.c.SEEK_END);
        fileToReturn.size = @intCast(libdragon.c.ftell(fileToReturn.fptr));
        _ = libdragon.c.rewind(fileToReturn.fptr);

        return fileToReturn;
    }

    pub fn close(self: *const File) void {
        _ = libdragon.c.fclose(self.fptr);
    }

    pub fn readline(self: *const File) ?Line {
        const ret = Line.init(self);

        if (ret.line_end == 0) {
            return null;
        }

        return ret;
    }
};
