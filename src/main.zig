const std = @import("std");
const Allocator = std.mem.Allocator;

const game = @import("level_allocator.zig");
const log = @import("logging.zig");
const assets = @import("assets.zig");

const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("malloc.h");
    @cInclude("string.h");
    @cInclude("stdint.h");
    @cInclude("contpad.h");
});

const libdragon = @cImport({
    @cInclude("libdragon.h");
    @cInclude("graphics.h");
});

const rdpq = @cImport({
    @cInclude("libdragon.h");
});

const rspq = @import("./libdragon/rspq.zig");

const t3d = @cImport({
    @cInclude("t3d/t3d.h");
    @cInclude("t3d/t3dmath.h");
    @cInclude("t3d/t3dmodel.h");
    @cInclude("t3d/t3dskeleton.h");
    @cInclude("t3d/t3danim.h");
});

var res = libdragon.RESOLUTION_320x240;
var bit: c_uint = libdragon.DEPTH_32_BPP;
const FB_COUNT = 3;

fn get_time_s() f32 {
    return libdragon.get_ticks_us() / 1000000.0;
}

fn filesize(pFile: *c.FILE) c_long
{
    _ = c.fseek( pFile, 0, c.SEEK_END );
    const lSize = c.ftell( pFile );
    c.rewind( pFile );

    return lSize;
}

fn read_sprite(spritename: [*c]const u8) *libdragon.sprite_t {
    const file: *c.FILE = c.fopen(spritename, "r");
    defer _ = c.fclose(file);

    const fsize = filesize(file);

    const buffer: *libdragon.sprite_t = @ptrCast(
        @alignCast(
            c.malloc(
                @intCast(fsize)
            )
        )
    );

    _ = c.fread(buffer, @sizeOf(u8), @intCast(fsize), file);

    return buffer;
}

fn zig_main() !void {
    libdragon.display_init(res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED);
    assets.init_compression(2);
    _ = libdragon.dfs_init(libdragon.DFS_DEFAULT_LOCATION);
    libdragon.joypad_init();

    t3d.t3d_init(.{});
    rdpq.rdpq_text_register_font(
        rdpq.FONT_BUILTIN_DEBUG_MONO,
        rdpq.rdpq_font_load_builtin(rdpq.FONT_BUILTIN_DEBUG_MONO)
    );

    const viewport = t3d.t3d_viewport_create_buffered(FB_COUNT);

    var frameIndex: i32 = 0;

    while (true) {
        frameIndex += 1;
        frameIndex = @mod(frameIndex, FB_COUNT);

        const pad = c.PollController(libdragon.JOYPAD_PORT_1);

        const disp = libdragon.display_get();



        libdragon.display_show(disp);

        rspq.block_begin();


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

