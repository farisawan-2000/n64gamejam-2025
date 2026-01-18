const std = @import("std");
const Allocator = std.mem.Allocator;

const constants = @import("constants.zig");
const tiny3d = @import("tiny3d/t3d.zig");

const Viewport = @import("tiny3d/viewport.zig").Viewport;
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Transform = @import("tiny3d/transform.zig").Transform;

const libdragon = @import("libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

const game = @import("game.zig");
const log = @import("logging.zig");
const assets = @import("assets.zig");
const math = @import("math.zig");
const contpad = @import("contpad.zig");
const Object = game.Object;
const Camera = game.Camera;
const Wipe = game.Wipe;
const level = game.level;

pub extern fn stop_game(arg_msg: [*c]const u8, arg_len: usize) noreturn;
pub extern fn test_screen() void;

// Override on the panic function, which eventually just hooks into libdragon assert
pub fn panic(msg: []const u8, stack_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    _ = stack_trace;
    _ = ret_addr;
    stop_game(msg.ptr, msg.len);

    while (true) {

    }
}

fn zig_main() !void {
    libdragon.c.display_init(libdragon.c.RESOLUTION_320x240, libdragon.c.DEPTH_32_BPP, 2, libdragon.c.GAMMA_NONE, libdragon.c.FILTERS_DISABLED);
    assets.init_compression(2);
    _ = libdragon.c.dfs_init(libdragon.c.DFS_DEFAULT_LOCATION);
    libdragon.c.joypad_init();

    libdragon.c.rdpq_init();
    tiny3d.init(tiny3d.DEFAULT_MTX_STACK_SIZE);

    level.load_new_level(@constCast("rom:/init.lvl")) catch unreachable;

    var wipe: Wipe = Wipe.init();

    var scheduled_id: u32 = 0;

    while (true) {
        contpad.update();

        const result = if (!wipe.ready) level.update() else .Ok;
        wipe.update();

        const disp = libdragon.c.display_get();
        const zbuf = libdragon.c.display_get_zbuf();

        rdpq.attach(disp, zbuf);

        level.draw();

        // screen transition over everything else
        rdpq.set_mode_standard();
        rdpq.mode_alphacompare(50);
        wipe.draw();

        rdpq.detach_show();

        if (wipe.ready) {
            level.handle_warp(scheduled_id);
            wipe.ready = false;
        }

        switch (result) {
            .Ok => continue,

            .Warp => |id| {
                wipe.goal = 1.0;

                scheduled_id = id;
            },
        }
    }
}

pub export fn main() void {
    _ = libdragon.c.debug_init_isviewer();
    log.log("STARTING!\n");
    zig_main() catch {
        log.log("Error!\n");
    };
}

