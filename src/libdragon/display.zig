const libdragon = @import("libdragon.zig");

pub fn get_delta_time() f32 {
    return libdragon.c.display_get_delta_time();
}


