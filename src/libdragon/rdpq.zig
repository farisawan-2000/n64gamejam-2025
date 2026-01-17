// Basically removing prefixes from functions
const libdragon = @import("libdragon.zig");

pub fn attach(cfb: *libdragon.c.surface_t, zbuf: *libdragon.c.surface_t) void {
    libdragon.c.rdpq_attach(cfb, zbuf);
}

pub fn detach_show() void {
    libdragon.c.rdpq_detach_show();
}

// pub fn textured_triangle(v1: [2]f32, v2: [2]f32, v3: [2]f32) void{

// }
// pub const CombinerMode = enum {
//     COMBINER_FLAT,
// };

pub extern fn set_combiner_mode_flat() void;
pub extern fn set_combiner_mode_shade() void;

pub fn set_fill_color(color: [4]u8) void {
    libdragon.c.rdpq_set_fill_color(.{
        .r = color[0],
        .g = color[1],
        .b = color[2],
        .a = color[3],
    });
}

pub fn set_prim_color(color: [4]u8) void {
    libdragon.c.rdpq_set_prim_color(.{
        .r = color[0],
        .g = color[1],
        .b = color[2],
        .a = color[3],
    });
}

pub fn colortri(v1: [2]f32, v2: [2]f32, v3: [2]f32, color: [4]f32) void {
    const v1color: [6]f32 = .{v1[0], v1[1], color[0], color[1], color[2], color[3]};
    const v2color: [6]f32 = .{v2[0], v2[1], color[0], color[1], color[2], color[3]};
    const v3color: [6]f32 = .{v3[0], v3[1], color[0], color[1], color[2], color[3]};

    libdragon.c.rdpq_triangle(
        &libdragon.c.TRIFMT_SHADE,
        &v1color[0], &v2color[0], &v3color[0]
    );
}

pub fn triangle(v1: [2]f32, v2: [2]f32, v3: [2]f32) void {
    libdragon.c.rdpq_triangle(
        &libdragon.c.TRIFMT_FILL,
        &v1[0], &v2[0], &v3[0]
    );
}

