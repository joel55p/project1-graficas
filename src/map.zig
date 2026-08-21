const rl = @import("raylib_c.zig").raylib;


pub const WIDTH: usize = 16;
pub const HEIGHT: usize = 16;

pub const grid = [HEIGHT][WIDTH]u8{
    .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    .{ 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1 },
    .{ 1, 0, 1, 0, 2, 0, 1, 1, 1, 0, 0, 3, 0, 1, 0, 1 },
    .{ 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1 },
    .{ 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1 },
    .{ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
    .{ 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1 },
    .{ 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 4, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1 },
    .{ 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1 },
    .{ 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1 },
    .{ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
    .{ 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 0, 2, 0, 2, 0, 2, 1, 0, 3, 0, 3, 0, 3, 9, 1 },
    .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
};

pub fn at(x: i32, y: i32) u8 {
    if (x < 0 or y < 0 or x >= @as(i32, @intCast(WIDTH)) or y >= @as(i32, @intCast(HEIGHT))) {
        return 1; // fuera del mapa cuenta como pared, asi nunca se sale de rango
    }
    return grid[@intCast(y)][@intCast(x)];
}

pub fn is_wall(cell: u8) bool {
    return cell != 0 and cell != 9;
}

pub fn is_goal(cell: u8) bool {
    return cell == 9;
}


pub fn wall_color(cell: u8, side: bool) rl.Color {
    const base: rl.Color = switch (cell) {
        1 => rl.Color{ .r = 180, .g = 60, .b = 60, .a = 255 }, // ladrillo
        2 => rl.Color{ .r = 60, .g = 140, .b = 200, .a = 255 }, // azul
        3 => rl.Color{ .r = 80, .g = 170, .b = 90, .a = 255 }, // verde
        4 => rl.Color{ .r = 200, .g = 170, .b = 60, .a = 255 }, // amarillo/dorado
        else => rl.Color{ .r = 200, .g = 200, .b = 200, .a = 255 },
    };
    if (side) {
        
        // (se ensancha a u16 antes de multiplicar para no desbordar el u8)
        return rl.Color{
            .r = @intCast(@as(u16, base.r) * 7 / 10),
            .g = @intCast(@as(u16, base.g) * 7 / 10),
            .b = @intCast(@as(u16, base.b) * 7 / 10),
            .a = 255,
        };
    }
    return base;
}
