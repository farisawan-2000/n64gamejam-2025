
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("malloc.h");
    @cInclude("string.h");
    @cInclude("stdint.h");
    @cInclude("libdragon.h");
});

const res = c.RESOLUTION_320x240;
const bit = c.DEPTH_32_BPP;

fn filesize(pFile: *c.FILE) i32 {
    c.fseek(pFile, 0, c.SEEK_END);
    const lSize = c.ftell(pFile);
    c.rewind(pFile);

    return lSize;
}

fn read_sprite(spritename: []u8) c.sprite_t {
    const fp: *c.FILE = c.fopen(spritename);
    defer c.fclose(fp);

    const sp: *c.sprite_t = c.malloc(c.filesize(fp));
    c.fread(sp, 1, c.filesize(fp), fp);

    return sp;
}

fn main() i32 {
    c.display_init(res, bit, 2, c.GAMMA_NONE, c.FILTERS_DISABLED);
    c.dfs_init(c.DFS_DEFAULT_LOCATION);
    c.joypad_init();
}


pub fn start() void {
    main();
}

