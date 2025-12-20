const std = @import("std");
const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("malloc.h");
    @cInclude("string.h");
    @cInclude("stdint.h");
    @cInclude("contpad.h");
});

const t3d = @cImport({
    @cInclude("t3d/t3d.h");
    @cInclude("t3d/t3dmath.h");
    @cInclude("t3d/t3dmodel.h");
    @cInclude("t3d/t3dskeleton.h");
    @cInclude("t3d/t3danim.h");
});

const tiny3d = @import("tiny3d/t3d.zig");

const Viewport = @import("tiny3d/viewport.zig").Viewport;
const Model = @import("tiny3d/model.zig").Model;
const Screen = @import("tiny3d/screen.zig").Screen;
const Vec3 = @import("tiny3d/vec3.zig").Vec3;
const Transform = @import("tiny3d/transform.zig").Transform;

const libdragon = @import("libdragon/libdragon.zig");
const rspq = libdragon.rspq;
const rdpq = libdragon.rdpq;

const game = @import("level_allocator.zig");
const log = @import("logging.zig");
const assets = @import("assets.zig");
const math = @import("math.zig");


var res = libdragon.c.RESOLUTION_320x240;
var bit: c_uint = libdragon.c.DEPTH_32_BPP;
const FB_COUNT = 3;


fn zig_main() !void {
    libdragon.c.display_init(res, bit, 2, libdragon.c.GAMMA_NONE, libdragon.c.FILTERS_DISABLED);
    assets.init_compression(2);
    _ = libdragon.c.dfs_init(libdragon.c.DFS_DEFAULT_LOCATION);
    libdragon.c.joypad_init();

    libdragon.c.rdpq_init();
    tiny3d.init(tiny3d.DEFAULT_MTX_STACK_SIZE);

    var viewport: Viewport = Viewport.create(FB_COUNT);

    const camPos: Vec3 = .{
        .xyz = .{0, 10.0, 40.0}
    };
    const camTarget: Vec3 = .{
        .xyz = .{0, 0.0, 0.0}
    };

    const ambientLightColor:     [4]u8 = .{80, 80, 100, 0xFF};
    const directionalLightColor: [4]u8 = .{0xEE, 0xAA, 0xAA, 0xFF};

    const lightDirVec: Vec3 = .{
        .xyz = .{-1, 1, 1}
    };

    var model = Model.load("rom:/model.t3dm");

    lightDirVec.normalize();

    var rotation: f32 = 0;

    const screen = Screen.make(.{
        100, 80, 80, 0xFF
    });

    while (true) {
        rotation -= 0.02;
        const modelScale = 0.1;

        viewport.set_projection(tiny3d.DEG_TO_RAD(85.0), 10.0, 150.0);
        viewport.look_at(camPos, camTarget, .{.xyz = .{0,1,0}});

        model.scale(modelScale);
        model.rotate(.{0.0, rotation*0.2, rotation});

        rdpq.attach(libdragon.c.display_get(), libdragon.c.display_get_zbuf());
        tiny3d.frame_start();
        viewport.attach();

        screen.clear();
        screen.clear_depth();

        tiny3d.light_set_ambient(ambientLightColor);
        tiny3d.light_set_directional(0, directionalLightColor, lightDirVec);
        tiny3d.light_set_count(1);

        model.draw();

        rdpq.detach_show();

        const pad = c.PollController(libdragon.c.JOYPAD_PORT_1);

        // make the compiler happy while i port
        if (pad.a) {
            log.log("A BUTTON\n");
            log.logU32(@intFromPtr(&viewport));
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
