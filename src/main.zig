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

const libdragon = @cImport({
    @cInclude("libdragon.h");
    @cInclude("graphics.h");
});

const rdpq = @cImport({
    @cInclude("libdragon.h");
});

const game = @import("level_allocator.zig");
const log = @import("logging.zig");
const assets = @import("assets.zig");
const math = @import("math.zig");

const rspq = @import("./libdragon/rspq.zig");

pub fn Vec3(xyz: [3]f32) t3d.T3DVec3 {
    var ret: t3d.T3DVec3 = undefined;
    ret.v = .{xyz[0], xyz[1], xyz[2]};

    return ret;
}

var res = libdragon.RESOLUTION_320x240;
var bit: c_uint = libdragon.DEPTH_32_BPP;
const FB_COUNT = 3;

fn zig_main() !void {
    libdragon.display_init(res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED);
    assets.init_compression(2);
    _ = libdragon.dfs_init(libdragon.DFS_DEFAULT_LOCATION);
    libdragon.joypad_init();

    libdragon.rdpq_init();
    t3d.t3d_init(.{});

    const modelMatQ: *[3]t3d.T3DMat4FP = @alignCast(
        @ptrCast(
            libdragon.malloc_uncached(@sizeOf(t3d.T3DMat4FP) * FB_COUNT)
        )
    );
    var viewport: tiny3d.Viewport = tiny3d.Viewport.create(FB_COUNT);

    const camPos: [3]f32 = .{0, 10.0, 40.0};
    const camTarget: [3]f32 = .{0, 0.0, 0.0};

    const colorAmbient: [4]u8 = .{80, 80, 100, 0xFF};
    const colorDir:     [4]u8 = .{0xEE, 0xAA, 0xAA, 0xFF};

    const lightDirVec = Vec3(.{-1, 1, 1});

    const model = t3d.t3d_model_load("rom:/model.t3dm");

    t3d.t3d_vec3_norm(@constCast(&lightDirVec));

    var frameIndex: i32 = 0;

    var rotation: f32 = 0;
    var drawBlock: *libdragon.rspq_block_t = undefined;
    var madeBlock: bool = false;

    while (true) {
        frameIndex += 1;
        frameIndex = @mod(frameIndex, FB_COUNT);

        rotation -= 0.02;
        const modelScale = 0.1;

        viewport.set_projection(t3d.T3D_DEG_TO_RAD(85.0), 10.0, 150.0);
        viewport.look_at(camPos, camTarget, .{0,1,0});


        const scale: [3]f32 = .{modelScale, modelScale, modelScale};
        const rot: [3]f32 = .{0.0, rotation*0.2, rotation};
        const move: [3]f32 = .{0,0,0};
        t3d.t3d_mat4fp_from_srt_euler(&modelMatQ[@bitCast(frameIndex)],
            &scale,
            &rot,
            &move
        );

        libdragon.rdpq_attach(libdragon.display_get(), libdragon.display_get_zbuf());
        t3d.t3d_frame_start();
        viewport.attach();

        t3d.t3d_screen_clear_color(t3d.RGBA32(100, 80, 80, 0xFF));
        t3d.t3d_screen_clear_depth();

        t3d.t3d_light_set_ambient(&colorAmbient);
        t3d.t3d_light_set_directional(0, &colorDir, &lightDirVec);
        t3d.t3d_light_set_count(1);

        if(madeBlock == false) {
            libdragon.rspq_block_begin();
                t3d.t3d_model_draw(model);
                t3d.t3d_matrix_pop(1);
            drawBlock = libdragon.rspq_block_end().?;
            madeBlock = true;
        }

        t3d.t3d_matrix_push(&modelMatQ[@bitCast(frameIndex)]);
        // for the actual draw, you can use the generic rspq-api.
        libdragon.rspq_block_run(drawBlock);

        libdragon.rdpq_detach_show();

        const pad = c.PollController(libdragon.JOYPAD_PORT_1);

        // make the compiler happy while i port
        if (pad.a) {
            log.log("A BUTTON\n");
            log.logU32(@intFromPtr(&viewport));
        }

    }
}

pub export fn main() void {
    _ = libdragon.debug_init_isviewer();
    log.log("STARTING!\n");
    zig_main() catch {
        log.log("Error!\n");
    };
}

