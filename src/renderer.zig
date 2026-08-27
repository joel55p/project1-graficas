const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const map = @import("map.zig");
const player_mod = @import("player.zig"); // el player_mod es el modulo del jugador, que contiene la estructura Player y sus funciones
const raycaster = @import("raycaster.zig");

//el techo y el piso que seria dos rectangulos que cubren la mitad de la pantalla cada uno.
const CEILING_COLOR = rl.Color{ .r = 40, .g = 40, .b = 55, .a = 255 };
const FLOOR_COLOR_A = rl.Color{ .r = 101, .g = 67, .b = 33, .a = 255 };  // cafe medio
const FLOOR_COLOR_B = rl.Color{ .r = 74, .g = 48, .b = 22, .a = 255 };   // cafe mas oscuro (la otra franja)
const FLOOR_STRIPE_WIDTH = 48; 


pub fn draw_scene(hits: []const raycaster.RayHit, screen_width: i32, screen_height: i32, pitch: f32) void {
    
    const half_h: f32 = @as(f32, @floatFromInt(screen_height)) / 2.0; // lo que hace es que divide la altura de la pantalla entre 2 para obtener el punto medio de la pantalla, que es donde se dibuja el horizonte
    var horizon: i32 = @intFromFloat(half_h + pitch); // de aqui se obtiene la coordenada y del horizonte, que es la mitad de la pantalla mas el pitch del jugador, para que cuando el jugador mire hacia arriba o hacia abajo, el horizonte se mueva hacia arriba o hacia abajo
    if (horizon < 0) horizon = 0; //si es menor que 0, se pone en 0 para que no se salga de la pantalla
    if (horizon > screen_height) horizon = screen_height;

    // dibujar el cielo y el piso como dos rectangulos, uno arriba y otro abajo del horizonte
    rl.DrawRectangle(0, 0, screen_width, horizon, CEILING_COLOR);

    const num_floor_rows = screen_height - horizon; 
    var row: i32 = 0;
    while (row < num_floor_rows) : (row += 1) {
        // t va de 0 (justo en el horizonte, lo mas lejos) a 1 
        const t: f32 = @as(f32, @floatFromInt(row)) / @as(f32, @floatFromInt(num_floor_rows)); //t es 

        // un cafe oscuro (lejos) y uno mas claro (cerca): color = oscuro + (claro - oscuro) * t
        const r: u8 = @intFromFloat(30.0 + (110.0 - 30.0) * t);
        const g: u8 = @intFromFloat(20.0 + (75.0 - 20.0) * t);
        const b: u8 = @intFromFloat(12.0 + (40.0 - 12.0) * t);

        rl.DrawRectangle(0, horizon + row, screen_width, 1, rl.Color{ .r = r, .g = g, .b = b, .a = 255 });
    }

    const num_rays = hits.len; // #rayos igual a lo recibido en el array de hits

    //ahora el  ancho de cada columna de pared que se va a dibujar, que es el ancho de la pantalla dividido entre el numero de rayos, para que se vea uniforme y no se vean huecos entre columnas
    const column_width: f32 = @as(f32, @floatFromInt(screen_width)) / @as(f32, @floatFromInt(num_rays)); 
    
    for (hits, 0..) |hit, i| { //for que se usa para dibujar cada columna de pared, usando la distancia del rayo para calcular la altura de la pared y el tipo de pared para calcular el color
        //convertir distancia en altura de pared
        const dist = if (hit.distance < 0.05) 0.05 else hit.distance; // dist es la distancia del jugador a la pared

        //entre mas chiquito el dist mas grande se va a ver la pared.
        //esencia visual del raycast, ya que la altura de la pared es inversamente proporcional a la dist, es decir, cuanto mas lejos esta la pared, mas baja se ve, y cuanto mas cerca esta, mas alta se ve
        const wall_height: f32 = @as(f32, @floatFromInt(screen_height)) / dist;  //altura = pantalla_alto / distancia
        
        //ahora bien esto centra verticalmente la pared en la pantalla, ya que el draw_start es la coordenada y donde se empieza a dibujar la pared, que es la mitad de la pantalla menos la mitad de la altura de la pared, para que quede centrada
        const draw_start = -wall_height / 2.0 + half_h + pitch;


        //const dibujar columna de pared
        const x: i32 = @intFromFloat(@as(f32, @floatFromInt(i)) * column_width);
        const w: i32 = @intFromFloat(@ceil(column_width));
        const y: i32 = @intFromFloat(draw_start);
        const h: i32 = @intFromFloat(wall_height);

        //por cada rayo es un rectangulo 
        rl.DrawRectangle(x, y, w, h, map.wall_color(hit.wall_type, hit.side));
    }
}

/// Minimapa en la esquina superior izquierda 
pub fn draw_minimap(player: *const player_mod.Player, cell_px: i32) void {
    const margin = 10;
    const border = 2; //se refiere a un borde negro que se dibuja alrededor

    const map_w = @as(i32, @intCast(map.WIDTH)) * cell_px; // es el ancho del mapa en píxeles
    const map_h = @as(i32, @intCast(map.HEIGHT)) * cell_px; // alto en pixeles

    rl.DrawRectangle(margin - border, margin - border, map_w + border * 2, map_h + border * 2, rl.BLACK);


    //recorre todo el mapa y dibuja cada celda como un cuadrito de cell_px en este caso 8px
    var y: i32 = 0;
    while (y < map.HEIGHT) : (y += 1) {
        var x: i32 = 0;
        while (x < map.WIDTH) : (x += 1) {
            const cell = map.at(x, y);
            const color = if (map.is_wall(cell))
                map.wall_color(cell, false)
            else if (map.is_goal(cell))
                rl.GOLD //meta!!!!
            else
                rl.Color{ .r = 25, .g = 25, .b = 25, .a = 255 }; 

            //por lo que literalmente mi grid de map pero en miniatura.
            rl.DrawRectangle(margin + x * cell_px, margin + y * cell_px, cell_px - 1, cell_px - 1, color);
        }
    }

    // Posicion del jugador en minipama -> convierte posicion a pixeles minimapa multipliando por cell_px y sumando el margen, para que no quede pegado a la esquina
    const px = margin + @as(i32, @intFromFloat(player.x * @as(f32, @floatFromInt(cell_px))));
    const py = margin + @as(i32, @intFromFloat(player.y * @as(f32, @floatFromInt(cell_px))));
    rl.DrawCircle(px, py, 3, rl.RED); //se muestra la poscion del player en rojo

    // Una linea corta mostrando hacia donde ve, para orientarse.
    const dir_len: f32 = @floatFromInt(cell_px);
    const dx = @cos(player.angle) * dir_len;
    const dy = @sin(player.angle) * dir_len;
    rl.DrawLine(px, py, px + @as(i32, @intFromFloat(dx)), py + @as(i32, @intFromFloat(dy)), rl.RED);
}

/// FPS visible en pantalla - funcion que ya trae raylib
pub fn draw_fps(x: i32, y: i32) void {
    const fps = rl.GetFPS();
    rl.DrawText(rl.TextFormat("FPS: %d", fps), x, y, 20, rl.LIME);
}