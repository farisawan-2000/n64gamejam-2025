const Model = @import("tiny3d/model.zig").Model;


pub const Level = struct {
    // Level:
    //  - Init from description file
    //  - List of models
    //  - List of warps
    //  - Camera start
    //  - 
    //  - 

    pub fn init(path: [:0]u8) Level {
        _ = path;
    }

    pub fn destroy() void {
        // 
    }
};