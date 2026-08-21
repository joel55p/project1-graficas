const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const map = @import("map.zig");

pub const Player = struct {

    x: f32,
    y: f32,
    angle: f32,

    move_speed: f32 = 2.5, // unidades de mapa por segundo
    rot_speed: f32 = 2.2, 
    mouse_sensitivity: f32 = 0.003, // radianes por pixel de mouse

    pub fn init(x: f32, y: f32, angle: f32) Player {
        return Player{ .x = x, .y = y, .angle = angle };
    }

   
    fn try_move(self: *Player, dx: f32, dy: f32) void {
        const new_x = self.x + dx;
        if (!map.is_wall(map.at(@intFromFloat(new_x), @intFromFloat(self.y)))) {
            self.x = new_x;
        }

        const new_y = self.y + dy;
        if (!map.is_wall(map.at(@intFromFloat(self.x), @intFromFloat(new_y)))) {
            self.y = new_y;
        }
    }

    pub fn handle_input(self: *Player, dt: f32) void {
        const forward_x = @cos(self.angle);
        const forward_y = @sin(self.angle);

        var move: f32 = 0;
        if (rl.IsKeyDown(rl.KEY_W)) move += 1;
        if (rl.IsKeyDown(rl.KEY_S)) move -= 1;

        if (move != 0) {
            const dist = move * self.move_speed * dt;
            self.try_move(forward_x * dist, forward_y * dist);
        }

       
        if (rl.IsKeyDown(rl.KEY_D)) self.angle += self.rot_speed * dt;
        if (rl.IsKeyDown(rl.KEY_A)) self.angle -= self.rot_speed * dt;

        //solo horizontal
        const mouse_delta = rl.GetMouseDelta();
        self.angle += mouse_delta.x * self.mouse_sensitivity;
    }
};
