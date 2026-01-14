const std = @import("std");

pub const Warp = struct {
    id: u32,
    level: [32:0]u8,


    pub fn init(in_id: u32, levelPath: [:0]const u8) Warp {
        var ret = Warp {
            .id = in_id,
            .level = undefined,
        };

        @memcpy(ret.level[0..levelPath.len], levelPath);

        ret.level[levelPath.len] = 0;

        return ret;
    }
};
