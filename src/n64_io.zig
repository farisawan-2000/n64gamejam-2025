const libdragon = @import("libdragon/libdragon.zig");
const log = @import("logging.zig");


pub fn tokenize() [][]u8 {

}

pub const Line = struct {
    buf: [1024]u8,
    line_end: u32,

    pub fn init(f: *const File) Line {
        var ret = Line {
            .buf = [_]u8 { 0 } ** 1024,
            .line_end = 0,
        };

        const bytes_read = libdragon.c.fread(&ret.buf, 1, 1024, f.fptr);
        for (0..bytes_read) |i| {
            if (ret.buf[i] == 0xA) {
                // newline, rewind the file a bit
                ret.line_end = i;
                for (i..1024) |rest| {
                    ret.buf[rest] = 0;
                }
                const remaining_bytes: i32 = @intCast(bytes_read - i);
                _ = libdragon.c.fseek(f.fptr, -remaining_bytes, libdragon.c.SEEK_CUR);
            }
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
        const ret = Line.init(self);

        if (ret.line_end == 0) {
            return null;
        }

        return ret;
    }
};
