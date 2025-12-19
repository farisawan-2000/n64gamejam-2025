// Basically so that we NEVER have to call extern c code outside of here
pub const c = @cImport({
    @cInclude("t3d/t3d.h");
    @cInclude("t3d/t3dmath.h");
    @cInclude("t3d/t3dmodel.h");
    @cInclude("t3d/t3dskeleton.h");
    @cInclude("t3d/t3danim.h");
});

const Model = @import("model.zig").Model;

pub const DEFAULT_MTX_STACK_SIZE = 0;

pub fn init(mtx_stack_size: i32) void {
    c.t3d_init(
        .{
            .matrixStackSize = mtx_stack_size,
        }
    );
}


