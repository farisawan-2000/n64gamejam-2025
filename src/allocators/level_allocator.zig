const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("malloc.h");
    @cInclude("string.h");
    @cInclude("stdint.h");
    @cInclude("contpad.h");
});

const std = @import("std");
const Allocator = std.mem.Allocator;
const Alignment = std.mem.Alignment;

pub const LevelAllocator: Allocator = struct {
    arena: ?[*]u8,
    top: u32,

    fn resize(
        self: *LevelAllocator,
        memory: []u8,
        alignment: Alignment,
        new_len: usize,
        return_address: usize,
    ) bool {
        _ = self;
        _ = memory;
        _ = alignment;
        _ = new_len;
        _ = return_address;
        return false;
    }

    fn alloc(
        self: *LevelAllocator,
        len: usize,
        alignment: Alignment,
        return_address: usize,
    ) ?[*]u8 {
        _ = return_address;

        if (self.arena == null) {
            self.arena = @ptrCast(c.malloc(1_048_576));
            self.top = 0;
        }

        c.assert(alignment.compare(.lte, .of(std.c.max_align_t)));
        // Note that this pointer cannot be aligncasted to max_align_t because if
        // len is < max_align_t then the alignment can be smaller. For example, if
        // max_align_t is 16, but the user requests 8 bytes, there is no built-in
        // type in C that is size 8 and has 16 byte alignment, so the alignment may
        // be 8 bytes rather than 16. Similarly if only 1 byte is requested, malloc
        // is allowed to return a 1-byte aligned pointer.
        self.top += len;
        return &self.arena[self.top];
    }

    fn remap(
        self: *LevelAllocator,
        memory: []u8,
        alignment: Alignment,
        new_len: usize,
        return_address: usize,
    ) ?[*]u8 {
        _ = self;
        _ = alignment;
        _ = return_address;
        return @ptrCast(c.realloc(memory.ptr, new_len));
    }

    fn free(
        self: *LevelAllocator,
        memory: []u8,
        alignment: Alignment,
        return_address: usize,
    ) void {
        _ = self;
        _ = alignment;
        _ = return_address;
        c.free(memory.ptr);
    }

    pub fn init() LevelAllocator {
        return .{
            .arena = null,
            .top = 0,
        };
    }

    pub fn initAllocator(self: *LevelAllocator) void {
        self.arena = .{
            .ptr = self,
            .vtable = .{
                .alloc = alloc,
                .resize = resize,
                .remap = remap,
                .free = free,
            }
        };
    }
};
