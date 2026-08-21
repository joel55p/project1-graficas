const std = @import("std");
const map = @import("map.zig");
const player_mod = @import("player.zig");


pub const RayHit = struct {
    distance: f32,
    wall_type: u8,
    side: bool, // false = cara este/oeste (vertical), true = norte/sur (horizontal)
};


pub fn cast_ray(origin_x: f32, origin_y: f32, angle: f32) RayHit {
    const ray_dir_x = @cos(angle);
    const ray_dir_y = @sin(angle);

    // En que celda del mapa esta  ahora mismo.
    var map_x: i32 = @intFromFloat(origin_x);
    var map_y: i32 = @intFromFloat(origin_y);

    
    const delta_dist_x: f32 = if (ray_dir_x == 0) 1e30 else @abs(1.0 / ray_dir_x);
    const delta_dist_y: f32 = if (ray_dir_y == 0) 1e30 else @abs(1.0 / ray_dir_y);

    var step_x: i32 = undefined;
    var step_y: i32 = undefined;
    var side_dist_x: f32 = undefined;
    var side_dist_y: f32 = undefined;

    
    if (ray_dir_x < 0) {
        step_x = -1;
        side_dist_x = (origin_x - @as(f32, @floatFromInt(map_x))) * delta_dist_x;
    } else {
        step_x = 1;
        side_dist_x = (@as(f32, @floatFromInt(map_x)) + 1.0 - origin_x) * delta_dist_x;
    }

    if (ray_dir_y < 0) {
        step_y = -1;
        side_dist_y = (origin_y - @as(f32, @floatFromInt(map_y))) * delta_dist_y;
    } else {
        step_y = 1;
        side_dist_y = (@as(f32, @floatFromInt(map_y)) + 1.0 - origin_y) * delta_dist_y;
    }

    var side = false;
    var wall_type: u8 = 1;

    
    var steps: u32 = 0;
    while (steps < 64) : (steps += 1) {
        if (side_dist_x < side_dist_y) {
            side_dist_x += delta_dist_x;
            map_x += step_x;
            side = false;
        } else {
            side_dist_y += delta_dist_y;
            map_y += step_y;
            side = true;
        }

        const cell = map.at(map_x, map_y);
        if (map.is_wall(cell)) {
            wall_type = cell;
            break;
        }
    }

    
    const perp_dist = if (!side)
        (side_dist_x - delta_dist_x)
    else
        (side_dist_y - delta_dist_y);

    return RayHit{ .distance = perp_dist, .wall_type = wall_type, .side = side };
}


pub fn cast_all(player: *const player_mod.Player, fov: f32, num_rays: usize, out: []RayHit) void {
    var i: usize = 0;
    while (i < num_rays) : (i += 1) {
        const t: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(num_rays - 1));
        const ray_angle = (player.angle - fov / 2.0) + fov * t;
        out[i] = cast_ray(player.x, player.y, ray_angle);
    }
}
