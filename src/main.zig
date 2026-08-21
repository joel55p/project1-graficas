const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const map = @import("map.zig");
const player_mod = @import("player.zig");
const raycaster = @import("raycaster.zig");
const renderer = @import("renderer.zig");

const SCREEN_WIDTH = 960;
const SCREEN_HEIGHT = 600;
const NUM_RAYS = 320; // menos rays = mas rapido, mas columnas gruesas
const FOV: f32 = std.math.pi / 3.0; // 60 grados

const State = enum { welcome, playing, success };

pub fn main() !void {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Raycaster");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const hits = try allocator.alloc(raycaster.RayHit, NUM_RAYS);
    defer allocator.free(hits);

    var player = player_mod.Player.init(1.5, 1.5, 0.0);
    var state: State = .welcome;

    while (!rl.WindowShouldClose()) {
        const dt = rl.GetFrameTime();

        switch (state) {
            .welcome => {
                if (rl.IsKeyPressed(rl.KEY_ENTER)) {
                    state = .playing;
                    rl.DisableCursor(); 
                }
            },
            .playing => {
                player.handle_input(dt);
                raycaster.cast_all(&player, FOV, NUM_RAYS, hits);

                if (map.is_goal(map.at(@intFromFloat(player.x), @intFromFloat(player.y)))) {
                    state = .success;
                    rl.EnableCursor();
                }
            },
            .success => {
                if (rl.IsKeyPressed(rl.KEY_R)) {
                    player = player_mod.Player.init(1.5, 1.5, 0.0);
                    state = .playing;
                    rl.DisableCursor();
                }
            },
        }

        rl.BeginDrawing();
        defer rl.EndDrawing();

        switch (state) {
            .welcome => draw_welcome_screen(),
            .playing => {
                renderer.draw_scene(hits, SCREEN_WIDTH, SCREEN_HEIGHT);
                renderer.draw_minimap(&player, 8);
                renderer.draw_fps(SCREEN_WIDTH - 110, 10);
            },
            .success => draw_success_screen(),
        }
    }
}

fn draw_welcome_screen() void {
    rl.ClearBackground(rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 });
    rl.DrawText("RAYCASTER", SCREEN_WIDTH / 2 - 160, SCREEN_HEIGHT / 2 - 80, 60, rl.RAYWHITE);
    rl.DrawText("Presiona ENTER para empezar", SCREEN_WIDTH / 2 - 180, SCREEN_HEIGHT / 2 + 10, 24, rl.LIGHTGRAY);
    rl.DrawText("W/S mover, A/D o mouse rotar", SCREEN_WIDTH / 2 - 180, SCREEN_HEIGHT / 2 + 45, 20, rl.GRAY);
}

fn draw_success_screen() void {
    rl.ClearBackground(rl.Color{ .r = 15, .g = 35, .b = 20, .a = 255 });
    rl.DrawText("NIVEL COMPLETADO", SCREEN_WIDTH / 2 - 240, SCREEN_HEIGHT / 2 - 60, 50, rl.GOLD);
    rl.DrawText("Presiona R para reiniciar", SCREEN_WIDTH / 2 - 160, SCREEN_HEIGHT / 2 + 20, 22, rl.RAYWHITE);
}
