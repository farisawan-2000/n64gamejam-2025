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

const libdragon = @cImport({
    @cInclude("libdragon.h");
    @cInclude("graphics.h");
});

pub extern "c" fn debugf(format: [*:0]const u8, ...) c_int;
pub extern "c" fn read_sprite(spritename: [*:0]const u8) *libdragon.sprite_t;

var res = libdragon.RESOLUTION_320x240;
var bit: c_uint = libdragon.DEPTH_32_BPP;

fn zig_main() !void {
    libdragon.display_init(res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED);
    _ = libdragon.dfs_init(libdragon.DFS_DEFAULT_LOCATION);
    libdragon.joypad_init();

    const mario = read_sprite("rom://mario.sprite");
    const mariotrans = read_sprite("rom://mariotrans.sprite");
    const mario16 = read_sprite("rom://mario16.sprite");
    const mariotrans16 = read_sprite("rom://mariotrans16.sprite");

    const red = read_sprite("rom://red.sprite");
    const green = read_sprite("rom://green.sprite");
    const blue = read_sprite("rom://blue.sprite");

    const red16 = read_sprite("rom://red16.sprite");
    const green16 = read_sprite("rom://green16.sprite");
    const blue16 = read_sprite("rom://blue16.sprite");

    _ = debugf("all sprites read!\n");

    while (true) {
        const disp = libdragon.display_get();

        // Display sprite (16bpp ones will only display in 16bpp mode, same with 32bpp)
        libdragon.graphics_draw_sprite( disp, 20, 150, mario );
        libdragon.graphics_draw_sprite_trans( disp, 150, 150, mariotrans );

        libdragon.graphics_draw_sprite( disp, 20, 150, mario16 );
        libdragon.graphics_draw_sprite_trans( disp, 150, 150, mariotrans16 );

        // 32BPP alpha blending test
        libdragon.graphics_draw_sprite_trans( disp, 150, 20, red );
        libdragon.graphics_draw_sprite_trans( disp, 170, 20, green );
        libdragon.graphics_draw_sprite_trans( disp, 160, 30, blue );

        // 16BPP trans test
        libdragon.graphics_draw_sprite_trans( disp, 150, 20, red16 );
        libdragon.graphics_draw_sprite_trans( disp, 170, 20, green16 );
        libdragon.graphics_draw_sprite_trans( disp, 160, 30, blue16 );

        libdragon.display_show(disp);

        const pad = c.PollController(libdragon.JOYPAD_PORT_1);

        if (pad.d_up != false) {
            _ = debugf("480i time!\n");
            libdragon.display_close();
            res = libdragon.RESOLUTION_640x480;
            libdragon.display_init(res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED);
        }

        if (pad.d_down != false) {
            _ = debugf("240p time!\n");
            libdragon.display_close();

            res = libdragon.RESOLUTION_320x240;
            libdragon.display_init(res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED);
        }

        if (pad.d_left != false) {
            _ = debugf("16bpp time!\n");
            libdragon.display_close();

            bit = libdragon.DEPTH_16_BPP;
            libdragon.display_init( res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED );
        }

        if (pad.d_right != false) {
            _ = debugf("32bpp time!\n");
            libdragon.display_close();

            bit = libdragon.DEPTH_32_BPP;
            libdragon.display_init( res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED );
        }
    }
}

pub export fn main() void {
    _ = libdragon.debug_init_isviewer();
    _ = debugf("STARTING!\n");
    zig_main() catch {
        _ = debugf("Error!\n");
    };
}

