const std = @import("std");
const invader_zig = @import("invader_zig");
const r1 = @import("raylib");

pub fn main() !void {
    // Initialization
    const screenWidth = 800;
    const screenHeight = 450;

    r1.initWindow(screenWidth, screenHeight, "example");
    defer r1.closeWindow();

    r1.setTargetFPS(60);

    while (!r1.windowShouldClose()) {

        r1.beginDrawing();
        defer r1.endDrawing();

        r1.clearBackground(.white);

        r1.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
    }
}
