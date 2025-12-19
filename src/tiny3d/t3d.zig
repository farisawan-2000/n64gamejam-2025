// main t3d include, plus some in-between glue so that things compile
pub const c = @cImport({
    @cInclude("t3d/t3d.h");
    @cInclude("t3d/t3dmath.h");
    @cInclude("t3d/t3dmodel.h");
    @cInclude("t3d/t3dskeleton.h");
    @cInclude("t3d/t3danim.h");
});

const Vec3 = @import("vec3.zig").Vec3;

//---------------------------------------------
//               INTERMEDIATE GLUE
//---------------------------------------------

pub fn light_set_directional(index: i32, color: *const [4]u8, direction: Vec3) void {
    var direction_t3d = direction.export_t3d();
    c.t3d_light_set_directional(index, color, &direction_t3d);
}

//---------------------------------------------
//               Tiny3D Code Start
//---------------------------------------------

const Model = @import("model.zig").Model;

pub const DEFAULT_MTX_STACK_SIZE = 0;

pub fn init(mtx_stack_size: i32) void {
    c.t3d_init(
        .{
            .matrixStackSize = mtx_stack_size,
        }
    );
}

pub fn frame_start() void {
    c.t3d_frame_start();
}

pub fn matrix_pop(count: i32) void {
    c.t3d_matrix_pop(count);
}

