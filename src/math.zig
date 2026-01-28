const libdragon = @import("libdragon/libdragon.zig");
const tiny3d = @import("tiny3d/t3d.zig");
const log = @import("logging.zig");

pub const pi = 3.14159265359;
pub const tau = 2 * pi;

pub fn distance3(a: [3]f32, b: [3]f32) f32 {
    return (a[0] * b[0]) + (a[1] * b[1]) + (a[2] * b[2]);
}

pub fn between3(a: [3]f32, b: [3]f32) [3]f32 {
    return .{
        ((a[0] + b[0]) / 2.0),
        ((a[1] + b[1]) / 2.0),
        ((a[2] + b[2]) / 2.0),
    };
}

pub fn atan2(x: f32, y: f32) f32 {
    return libdragon.c.atan2f(x, y);
}

pub fn sin(x: f32) f32 {
    return libdragon.c.sinf(x);
}

pub fn cos(x: f32) f32 {
    return libdragon.c.cosf(x);
}

pub fn radian_clamp(x: *f32) void {
    while (x.* >= tau) : (x.* -= tau) {}
    while (x.* <= -tau) : (x.* += tau) {}
}

pub fn degree_clamp(x: *f32) void {
    while (x.* >= 360) : (x.* -= 360) {}
    while (x.* <= -360) : (x.* += 360) {}
}

pub fn deg_to_rad(x: f32) f32 {
    return tiny3d.DEG_TO_RAD(x);
}

pub fn mag2(comptime T: type, x: T, y: T) f32 {
    const val = (x * x) + (y * y);
    return tiny3d.c.sqrtf(@floatFromInt(val));
}
