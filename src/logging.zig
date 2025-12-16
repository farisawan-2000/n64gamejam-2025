const std = @import("std");

fn logU32(val: c_ulong) void {
    var buf: [1000]u8 = undefined;

    const msg = std.fmt.bufPrintZ(&buf, "Value: {x}\n", .{val}) catch unreachable;

    _ = debugf(msg);
}
