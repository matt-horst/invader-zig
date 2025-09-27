const std = @import("std");
const invader_zig = @import("invader_zig");
const rl = @import("raylib");

const DrawableObject = struct {
    posX: i32,
    posY: i32,
    tex: rl.Texture2D,

    pub fn draw(self: @This()) void {
        rl.drawTexture(self.tex, self.posX, self.posY, .white);
    }
};

fn update_image_with_pixel_data(img: *rl.Image, pixels: []const i32, color: rl.Color) void {
    for (pixels, 0..) |p, i| {
        const x: i32 = @mod(@as(i32, @intCast(i)), @as(i32, @intCast(img.width)));
        const y: i32 = @divTrunc(@as(i32, @intCast(i)), @as(i32, @intCast(img.width)));

        const pixel_color: rl.Color = if (p == 0) .black else color;

        rl.imageDrawPixel(img, x, y, pixel_color);
    }
}

fn create_alien_texture() rl.RaylibError!rl.Texture2D {
    const width = 11;
    const height = 8;
    const pixels: [height * width]i32 = .{
        0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, // ..#.....#..
        0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, // ...#...#...
        0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, // ..#######..
        0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, // .##.###.##.
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, // ###########
        1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, // #.#######.#
        1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, // #.#.....#.#
        0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, // ...##.##...
    };

    var img = rl.genImageColor(width, height, .white);
    defer rl.unloadImage(img);

    update_image_with_pixel_data(&img, &pixels, .red);

    const tex = try rl.loadTextureFromImage(img);

    return tex;
}

fn create_player_texture() rl.RaylibError!rl.Texture2D {
    const width = 11;
    const height = 7;
    const pixels: [height * width]i32 = .{
        0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, // .....#.....
        0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, // ....###....
        0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, // ....###....
        0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, // .#########.
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, // ###########
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, // ###########
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, // ###########
    };

    var img = rl.genImageColor(width, height, .white);
    defer rl.unloadImage(img);

    update_image_with_pixel_data(&img, &pixels, .white);

    const tex = try rl.loadTextureFromImage(img);

    return tex;
}

pub fn main() !void {
    // Initialization
    const zoom = 2;
    const screenWidth = 640;
    const screenHeight = 480;

    rl.initWindow(screenWidth * zoom, screenHeight * zoom, "example");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const alien = try create_alien_texture();
    defer rl.unloadTexture(alien);

    const player = try create_player_texture();
    defer rl.unloadTexture(player);

    const camera: rl.Camera2D = .{.offset = .{.x = 0, .y = 0}, .rotation = 0, .target = .{.x = 0, .y = 0}, .zoom = zoom};

    var alienObject: DrawableObject = .{.tex = alien, .posX = screenWidth / 2, .posY = screenHeight / 2};
    var playerObject: DrawableObject = .{.tex = player, .posX = screenWidth / 2, .posY = screenHeight - player.height};

    const objects = [_]*DrawableObject{&alienObject, &playerObject};

    while (!rl.windowShouldClose()) {
        // Handle inputs
        if (rl.isKeyDown(.a)) {
            // Move left
            playerObject.posX -= 2;
        }

        if (rl.isKeyDown(.d)) {
            // Move right
            playerObject.posX += 2;
        }

        
        // Draw screen
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode2D(camera);
        defer rl.endMode2D();

        rl.clearBackground(.black);

        for (objects) |obj| {
            obj.draw();
        }
    }
}
