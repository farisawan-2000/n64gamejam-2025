// Basically so that we NEVER have to call extern c code outside of here
const c = @cImport({
    @cInclude("t3d/t3d.h");
    @cInclude("t3d/t3dmath.h");
    @cInclude("t3d/t3dmodel.h");
    @cInclude("t3d/t3dskeleton.h");
    @cInclude("t3d/t3danim.h");
});

// Constructs a T3DVec3 from a [3]f32 so that we can talk to C
fn T3DVec3(xyz: [3]f32) c.T3DVec3 {
    var ret: c.T3DVec3 = undefined;
    ret.v = .{xyz[0], xyz[1], xyz[2]};

    return ret;
}

