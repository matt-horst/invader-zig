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

const SpriteSheet = struct {
    frame_width: i32,
    frame_height: i32,
    img: rl.Image,

    pub fn draw() void {}

    pub fn new(frame_width: i32, frame_height: i32, sheet_width: i32, sheet_height: i32) @This() {
        return .{
            .frame_width = frame_width,
            .frame_height = frame_height,
            .img = rl.genImageColor(sheet_width, sheet_height, .black),
        };
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

    update_image_with_pixel_data(&img, &pixels, .white);

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

    update_image_with_pixel_data(&img, &pixels, .green);

    const tex = try rl.loadTextureFromImage(img);

    return tex;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Initialization
    const zoom = 2;
    const screenWidth = 640;
    const screenHeight = 480;

    rl.initWindow(screenWidth * zoom, screenHeight * zoom, "Space Invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const alien = try create_alien_texture();
    defer rl.unloadTexture(alien);

    const player = try create_player_texture();
    defer rl.unloadTexture(player);

    const camera: rl.Camera2D = .{ .offset = .{ .x = 0, .y = 0 }, .rotation = 0, .target = .{ .x = 0, .y = 0 }, .zoom = zoom };

    // var alienObject: DrawableObject = .{.tex = alien, .posX = screenWidth / 2, .posY = screenHeight / 2};
    var playerObject: DrawableObject = .{ .tex = player, .posX = screenWidth / 2, .posY = screenHeight - player.height };

    // const objects = [_]*DrawableObject{&alienObject, &playerObject};
    var entities = std.ArrayList(*DrawableObject){};
    defer entities.deinit(allocator);

    try entities.append(allocator, &playerObject);

    var swarm: [5][11]DrawableObject = undefined;
    for (0..5) |i| {
        for (0..11) |j| {
            swarm[i][j] = .{ .tex = alien, .posX = @intCast(j * 24), .posY = @intCast(i * 24) };
            try entities.append(allocator, &swarm[i][j]);
        }
    }

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

        // Handle collisions

        // Draw screen
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode2D(camera);
        defer rl.endMode2D();

        rl.clearBackground(.black);

        for (entities.items) |obj| {
            obj.draw();
        }
    }
}
