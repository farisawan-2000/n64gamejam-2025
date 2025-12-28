const libdragon = @import("libdragon/libdragon.zig");

pub fn tokenize() [][]u8 {

}

pub const File = struct {
    fptr: *libdragon.c.FILE,

    pub fn open(path: [:0]const u8) File {
        return .{
            .fptr = libdragon.c.fopen(path, "r"),
        };
    }

    pub fn close(self: *const File) void {
        _ = libdragon.c.fclose(self.fptr);
    }

    pub fn readline(self: *const File) ?[]u8 {
        _ = self;
        return null;
    }
};
