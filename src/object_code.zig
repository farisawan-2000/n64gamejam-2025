const Object = @import("object.zig").Object;

pub fn default_init(o: *Object) void {
    _ = o;
}

pub fn default_update(o: *Object) void {
    _ = o;
}


pub fn gear_update(o: *Object) void {
    o.rot[2] -= 0.02;
    o.rot[1] -= 0.004;
    o.rot[0] = 0;
    o.scale = .{
        0.1,
        0.1,
        0.1
    };
}
