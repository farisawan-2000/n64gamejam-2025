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
const Level = game.Level;

pub extern fn stop_game(arg_msg: [*c]const u8, arg_len: usize) noreturn;

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

    // var cam = Camera.init(
    //     .{0, 10.0, 40.0},
    // );

    // var theObj = Object.init(
    //     objcode.default_init,
    //     objcode.gear_update,
    //     "rom:/model.t3dm"
    // );

    var initLevel = Level.init(@constCast("rom:/init.lvl")) catch unreachable;

    while (true) {
        contpad.update();

        initLevel.tick();
        initLevel.draw();
    }
}

pub export fn main() void {
    _ = libdragon.c.debug_init_isviewer();
    log.log("STARTING!\n");
    zig_main() catch {
        log.log("Error!\n");
    };
}

