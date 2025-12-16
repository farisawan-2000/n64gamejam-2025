const std = @import("std");

pub extern "c" fn debugf(format: [*:0]const u8, ...) c_int;

pub fn log(msg: [:0]const u8) void {
    _ = debugf(msg);
}

pub fn logU32(val: c_ulong) void {
    var buf: [1000]u8 = undefined;

    const msg = std.fmt.bufPrintZ(&buf, "Value: {x}\n", .{val}) catch unreachable;

    _ = debugf(msg);
}
