const std = @import("std");
const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("malloc.h");
    @cInclude("string.h");
    @cInclude("stdint.h");
});

const libdragon = @cImport({
    @cInclude("libdragon.h");
    @cInclude("graphics.h");
});

var res = libdragon.RESOLUTION_320x240;
const bit = libdragon.DEPTH_32_BPP;

fn filesize(pFile: *c.FILE) usize {
    _ = c.fseek(pFile, 0, c.SEEK_END);
    const lSize = c.ftell(pFile);
    c.rewind(pFile);

    return @intCast(lSize);
}

fn read_sprite(allocator: Allocator, spritename: [:0]const u8) !*libdragon.sprite_t {
    const fp: *c.FILE = c.fopen(spritename , "r");
    defer _ = c.fclose(fp);

    const sp = try allocator.create(libdragon.sprite_t);
    _ = c.fread(sp, 1, filesize(fp), fp);

    return sp;
}

pub fn start() void {
    libdragon.display_init(res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED);
    _ = libdragon.dfs_init(libdragon.DFS_DEFAULT_LOCATION);
    libdragon.joypad_init();

    const mario: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://mario.sprite");
    const mariotrans: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://mariotrans.sprite");
    const mario16: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://mario16.sprite");
    const mariotrans16: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://mariotrans16.sprite");

    const red: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://red.sprite");
    const green: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://green.sprite");
    const blue: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://blue.sprite");

    const red16: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://red16.sprite");
    const green16: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://green16.sprite");
    const blue16: *libdragon.sprite_t = read_sprite(std.heap.raw_c_allocator, "rom://blue16.sprite");

    while (true) {
        const disp: libdragon.display_context_t = libdragon.display_get();

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

        // libdragon.joypad_poll();
        // const keys: libdragon.joypad_buttons_t = libdragon.joypad_get_buttons_pressed(libdragon.JOYPAD_PORT_1);

        // if (keys.d_up != false) {
        //     libdragon.display_close();
        //     res = libdragon.RESOLUTION_640x480;
        //     libdragon.display_init(res, bit, 2, libdragon.GAMMA_NONE, libdragon.FILTERS_DISABLED);
        // }
    }
}

