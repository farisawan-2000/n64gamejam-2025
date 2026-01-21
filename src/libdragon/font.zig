const libdragon = @import("libdragon.zig");

var curLoadedFonts: i32 = 1;

pub const Font = struct {
    internal_font_ptr: ?*libdragon.c.rdpq_font_t,
    internal_font_num: i32,

    pub fn init(fontpath: *[:0]u8) Font {
        var ret = Font {
            .internal_font_ptr = null,
            .internal_font_num = 0,
        };

        ret.internal_font_ptr = libdragon.c.rdpq_font_load(fontpath);
        ret.internal_font_num = curLoadedFonts;

        curLoadedFonts += 1;

        libdragon.c.rdpq_text_register_font(ret.internal_font_num, ret.internal_font_ptr);

        return ret;
    }

    pub fn getFontNum(self: *const Font) i32 {
        return self.internal_font_num;
    }
};

pub const Textbox = struct {
    fileptr: ?*libdragon.c.FILE,
    cursor_position: i32,

    pub fn init(textpath: [:0]u8, x: u32, y: u32, w: u32, h: u32) Textbox {
        // open file
        // 
    }

    pub fn draw() void {
        rdpq_paragraph_t* par = rdpq_paragraph_build(&(rdpq_textparms_t){
            // .line_spacing = -3,
            .align = ALIGN_LEFT,
            .valign = VALIGN_CENTER,
            .width = box_width,
            .height = box_height,
            .wrap = WRAP_WORD,
        }, FONT_PACIFICO, text, &self.cursor_position);

        rdpq_paragraph_render(par, x0, y0);
        rdpq_paragraph_free(par);
    }
};
