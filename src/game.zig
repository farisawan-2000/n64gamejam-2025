pub const level = @import("level.zig");
pub const Object = @import("object.zig").Object;
pub const Camera = @import("camera.zig").Camera;

pub const Game = struct {
    // Game State:
    //  - Current level
    currentLevel: level.Level,
    //  - Controller polling?
    //  - 
    //  - 
    //  - 

    pub fn init() Game {

    }

    pub fn tick() void {
        // 
    }

    pub fn render() void {
        // 
    }
};