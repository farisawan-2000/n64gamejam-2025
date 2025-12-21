const std = @import("std");
const Allocator = std.mem.Allocator;

const constants = @import("constants.zig");

const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("malloc.h");
    @cInclude("string.h");
    @cInclude("stdint.h");
    @cInclude("contpad.h");
});

const tiny3d = @import("tiny3d/t3d.zig");

const Viewport = @import("tiny3d/viewport.zig").Viewport;
const Screen = @import("tiny3d/screen.zig").Screen;
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Transform = @import("tiny3d/transform.zig").Transform;

const libdragon = @import("libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

const game = @import("game.zig");
const log = @import("logging.zig");
const assets = @import("assets.zig");
const math = @import("math.zig");
const objcode = @import("object_code.zig");
const Object = game.Object;
const Camera = game.Camera;

fn zig_main() !void {
    libdragon.c.display_init(libdragon.c.RESOLUTION_320x240, libdragon.c.DEPTH_32_BPP, 2, libdragon.c.GAMMA_NONE, libdragon.c.FILTERS_DISABLED);
    assets.init_compression(2);
    _ = libdragon.c.dfs_init(libdragon.c.DFS_DEFAULT_LOCATION);
    libdragon.c.joypad_init();

    libdragon.c.rdpq_init();
    tiny3d.init(tiny3d.DEFAULT_MTX_STACK_SIZE);

    var cam = Camera.init(
        .{0, 10.0, 40.0},
        .{0, 0.0, 0.0}
    );

    const ambientLightColor:     [4]u8 = .{80, 80, 100, 0xFF};
    const directionalLightColor: [4]u8 = .{0xEE, 0xAA, 0xAA, 0xFF};

    const lightDirVec: Vec3 = .{
        .xyz = .{-1, 1, 1}
    };

    var theObj = Object.init(
        objcode.default_init,
        objcode.gear_update,
        "rom:/model.t3dm"
    );

    lightDirVec.normalize();

    const screen = Screen.make(.{
        100, 80, 80, 0xFF
    });

    while (true) {
        const pad = c.PollController(libdragon.c.JOYPAD_PORT_1);

        // make the compiler happy while i port
        if (pad.a) {
            log.log("A BUTTON\n");
        }

        theObj.update();

        rdpq.attach(libdragon.c.display_get(), libdragon.c.display_get_zbuf());
        tiny3d.frame_start();
        cam.update();

        screen.clear();
        screen.clear_depth();

        tiny3d.light_set_ambient(ambientLightColor);
        tiny3d.light_set_directional(0, directionalLightColor, lightDirVec);
        tiny3d.light_set_count(1);

        theObj.draw();

        rdpq.detach_show();
    }
}

pub export fn main() void {
    _ = libdragon.c.debug_init_isviewer();
    log.log("STARTING!\n");
    zig_main() catch {
        log.log("Error!\n");
    };
}
