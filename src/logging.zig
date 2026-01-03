const std = @import("std");

pub extern "c" fn debugf(format: [*:0]const u8, ...) c_int;

pub fn log(msg: [:0]const u8) void {
    _ = debugf(msg);
}

pub fn log2(msg: []const u8) void {
    var buf: [1000]u8 = undefined;

    const msgbuf = std.fmt.bufPrintZ(&buf, "{s}\n", .{msg}) catch unreachable;

    _ = debugf(msgbuf);
}

pub fn logVec(val: [3]f32) void {
    var buf: [1000]u8 = undefined;

    const msg = std.fmt.bufPrintZ(&buf, "Value: {{ {d}, {d}, {d} }}\n", .{val[0], val[1], val[2]}) catch unreachable;

    _ = debugf(msg);
}

pub fn logU32(val: c_ulong) void {
    var buf: [1000]u8 = undefined;

    const msg = std.fmt.bufPrintZ(&buf, "Value: {x}\n", .{val}) catch unreachable;

    _ = debugf(msg);
}
