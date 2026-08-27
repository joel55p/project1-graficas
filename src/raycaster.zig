const std = @import("std");
const map = @import("map.zig");
const player_mod = @import("player.zig");


pub const RayHit = struct { //estructura de datos que representa  resultado de un rayo lanzado desde la posición del jugador, contiene la distancia a la pared, el tipo de pared y si es un lado u otro
    distance: f32,
    wall_type: u8,
    side: bool, // side va a ser true si el rayo golpea una pared vertical y false si golpea una pared horizontal
};

//esta funcion es la que hace el raycasting, es decir, la que calcula la distancia a la pared mas cercana en la direccion del rayo
pub fn cast_ray(origin_x: f32, origin_y: f32, angle: f32) RayHit {
    //igual que en player, el vector direccion del rayo se calcula con trigonometria, usando coseno y seno del angulo del rayo
    const ray_dir_x = @cos(angle); // es el coseno del angulo del rayo, que es la direccion en x del rayo
    const ray_dir_y = @sin(angle); // direccion y del rayo, es el seno del angulo del rayo

    // En que celda del mapa esta  ahora mismo.
    var map_x: i32 = @intFromFloat(origin_x);
    var map_y: i32 = @intFromFloat(origin_y);

    
    // Distancia que el rayo tiene que recorrer para ir de una celda a la siguiente en x o y
    const delta_dist_x: f32 = if (ray_dir_x == 0) 1e30 else @abs(1.0 / ray_dir_x);

    //caso especial de delta_dist_x y delta_dist_y, si el rayo es paralelo a un eje, la distancia es infinita, por eso se usa 1e30 como valor grande
    const delta_dist_y: f32 = if (ray_dir_y == 0) 1e30 else @abs(1.0 / ray_dir_y);



    // se coloca undefined para que se inicialice despues, ya que depende de la direccion del rayo
    var step_x: i32 = undefined;
    var step_y: i32 = undefined;
    var side_dist_x: f32 = undefined; 
    var side_dist_y: f32 = undefined;

    //hacia que lado se avanza y tan lejos esta la primera linea 
    if (ray_dir_x < 0) { //si direccion del rayo es negativa en x
        step_x = -1; // se avanza hacia la izquierda
        side_dist_x = (origin_x - @as(f32, @floatFromInt(map_x))) * delta_dist_x; // esto es  la distancia desde la posicion del jugador hasta la primera linea vertical que se cruza en la direccion del rayo
    } else {
        step_x = 1; //si es positiva, se avanza hacia la derech
        side_dist_x = (@as(f32, @floatFromInt(map_x)) + 1.0 - origin_x) * delta_dist_x; // lo mismo
    }

    //lo mismo para y
    if (ray_dir_y < 0) {
        step_y = -1;
        side_dist_y = (origin_y - @as(f32, @floatFromInt(map_y))) * delta_dist_y;
    } else {
        step_y = 1;
        side_dist_y = (@as(f32, @floatFromInt(map_y)) + 1.0 - origin_y) * delta_dist_y;
    }

    // DDA loop: se avanza celda por celda hasta que se encuentra una pared, se usa un contador de pasos para evitar bucles infinitos
    var side = false; //side es 
    var wall_type: u8 = 1;

    var steps: u32 = 0;
    while (steps < 64) : (steps += 1) { // mientras no se haya encontrado una pared y no se haya llegado al limite de pasos, se sigue avanzando
        if (side_dist_x < side_dist_y) { //si la distancia a la siguiente linea vertical es menor que la distancia a la siguiente linea horizontal, se avanza en x
            
            //entonces se avanza en x, se actualiza la distancia a la siguiente linea vertical y se actualiza la celda del mapa en x
            side_dist_x += delta_dist_x;
            map_x += step_x;
            side = false;  //x
        } else { // lo contrario, se avanza en y, se actualiza la distancia a la siguiente linea horizontal y se actualiza la celda del mapa en y
            side_dist_y += delta_dist_y;
            map_y += step_y;
            side = true;  //y
        }

        const cell = map.at(map_x, map_y);
        if (map.is_wall(cell)) { //revision si la celda nueva es una pared, si es asi se guarda el tipo de pared y se sale del bucle
            wall_type = cell;
            break;
        }
    }

    
    //para que no se vea mal sino que se vea uniforme
    const perp_dist = if (!side) //horizontal si es falso, vertical si es verdadero
        (side_dist_x - delta_dist_x) //se resta un delta_dist extra porque en el loop ya se sumo uno extra al avanzar a la siguiente celda, entonces se resta para obtener la distancia real desde el origen hasta la pared
    else
        (side_dist_y - delta_dist_y); // igual pero en y

    return RayHit{ .distance = perp_dist, .wall_type = wall_type, .side = side }; // return de la estructura con la distancia, el tipo de pared y si es un lado u otro
}


//Funcion que reparte num_rays rayos en el campo de vision del jugador, y guarda los resultados en el array out, que debe tener al menos num_rays elementos
pub fn cast_all(player: *const player_mod.Player, fov: f32, num_rays: usize, out: []RayHit) void {
    var i: usize = 0;
    while (i < num_rays) : (i += 1) {
        const t: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(num_rays - 1));
        const ray_angle = (player.angle - fov / 2.0) + fov * t;
        out[i] = cast_ray(player.x, player.y, ray_angle);
    }
}
