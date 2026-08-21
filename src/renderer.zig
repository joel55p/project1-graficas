const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const map = @import("map.zig");
const player_mod = @import("player.zig");
const raycaster = @import("raycaster.zig");

const CEILING_COLOR = rl.Color{ .r = 40, .g = 40, .b = 55, .a = 255 };
const FLOOR_COLOR = rl.Color{ .r = 55, .g = 50, .b = 45, .a = 255 };


pub fn draw_scene(hits: []const raycaster.RayHit, screen_width: i32, screen_height: i32) void {
    rl.DrawRectangle(0, 0, screen_width, @divTrunc(screen_height, 2), CEILING_COLOR);
    rl.DrawRectangle(0, @divTrunc(screen_height, 2), screen_width, @divTrunc(screen_height, 2), FLOOR_COLOR);

    const num_rays = hits.len;
    const column_width: f32 = @as(f32, @floatFromInt(screen_width)) / @as(f32, @floatFromInt(num_rays));

    for (hits, 0..) |hit, i| {
        const dist = if (hit.distance < 0.05) 0.05 else hit.distance;

        const wall_height: f32 = @as(f32, @floatFromInt(screen_height)) / dist;
        const draw_start = -wall_height / 2.0 + @as(f32, @floatFromInt(screen_height)) / 2.0;

        const x: i32 = @intFromFloat(@as(f32, @floatFromInt(i)) * column_width);
        const w: i32 = @intFromFloat(@ceil(column_width));
        const y: i32 = @intFromFloat(draw_start);
        const h: i32 = @intFromFloat(wall_height);

        rl.DrawRectangle(x, y, w, h, map.wall_color(hit.wall_type, hit.side));
    }
}

/// Minimapa en la esquina superior izquierda 
pub fn draw_minimap(player: *const player_mod.Player, cell_px: i32) void {
    const margin = 10;
    const border = 2;

    const map_w = @as(i32, @intCast(map.WIDTH)) * cell_px;
    const map_h = @as(i32, @intCast(map.HEIGHT)) * cell_px;

    rl.DrawRectangle(margin - border, margin - border, map_w + border * 2, map_h + border * 2, rl.BLACK);

    var y: i32 = 0;
    while (y < map.HEIGHT) : (y += 1) {
        var x: i32 = 0;
        while (x < map.WIDTH) : (x += 1) {
            const cell = map.at(x, y);
            const color = if (map.is_wall(cell))
                map.wall_color(cell, false)
            else if (map.is_goal(cell))
                rl.GOLD
            else
                rl.Color{ .r = 25, .g = 25, .b = 25, .a = 255 };

            rl.DrawRectangle(margin + x * cell_px, margin + y * cell_px, cell_px - 1, cell_px - 1, color);
        }
    }

    // Posicion del jugador en minipama
    const px = margin + @as(i32, @intFromFloat(player.x * @as(f32, @floatFromInt(cell_px))));
    const py = margin + @as(i32, @intFromFloat(player.y * @as(f32, @floatFromInt(cell_px))));
    rl.DrawCircle(px, py, 3, rl.RED);

    // Una linea corta mostrando hacia donde ve, para orientarse.
    const dir_len: f32 = @floatFromInt(cell_px);
    const dx = @cos(player.angle) * dir_len;
    const dy = @sin(player.angle) * dir_len;
    rl.DrawLine(px, py, px + @as(i32, @intFromFloat(dx)), py + @as(i32, @intFromFloat(dy)), rl.RED);
}

/// FPS visible en pantalla
pub fn draw_fps(x: i32, y: i32) void {
    const fps = rl.GetFPS();
    rl.DrawText(rl.TextFormat("FPS: %d", fps), x, y, 20, rl.LIME);
}
