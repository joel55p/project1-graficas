const rl = @import("raylib_c.zig").raylib; //lo que hace es que importa la libreria raylib y le da el alias rl para poder usarla mas facil

//se define el tamaño del mundo
pub const WIDTH: usize = 16;
pub const HEIGHT: usize = 16;

pub const grid = [HEIGHT][WIDTH]u8{ // en si mi nivel es una matriz de numeros
    .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },  //0 es piso cambiante, 1-4 son tipos de pared, 9 es la meta
    .{ 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1 },
    .{ 1, 0, 1, 0, 2, 0, 1, 1, 1, 0, 0, 3, 0, 1, 0, 1 }, //u8 en si es porque es un entero sin signo de 8 bits, es decir, un numero entre 0 y 255
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
//funcion que se usa como tipo seguridad sobre el mapa

pub fn at(x: i32, y: i32) u8 { // el i32 es porque es un entero con signo de 32 bits, es decir, un numero entre -2147483648 y 2147483647
    if (x < 0 or y < 0 or x >= @as(i32, @intCast(WIDTH)) or y >= @as(i32, @intCast(HEIGHT))) { //si se quiere pasar de lo limites del mapa.
        return 1; // si esta fuera entonces igual devuelve pared asi nunca se sale, para que no crashee el game
    }
    return grid[@intCast(y)][@intCast(x)]; //sino pues retorna el valor de la celda en la matriz, que puede ser 0, 1, 2, 3, 4 o 9 dependiendo de la celda
}


//funcion que define si una celda es pared o no, para que el jugador no pueda pasar por ahi
pub fn is_wall(cell: u8) bool {
    return cell != 0 and cell != 9; // todo lo que no sea 0 o 9 es pared
}

pub fn is_goal(cell: u8) bool {
    return cell == 9;
}


//funcion que define el color de la pared dependiendo del tipo de celda y si es un lado o no, para que se vea mas realista
pub fn wall_color(cell: u8, side: bool) rl.Color {
    const base: rl.Color = switch (cell) {  //valores RGB para paredes con un switch simple
        1 => rl.Color{ .r = 180, .g = 60, .b = 60, .a = 255 }, // ladrillo tipo rojito
        2 => rl.Color{ .r = 60, .g = 140, .b = 200, .a = 255 }, // azul
        3 => rl.Color{ .r = 80, .g = 170, .b = 90, .a = 255 }, // verde
        4 => rl.Color{ .r = 200, .g = 170, .b = 60, .a = 255 }, // amarillo
        else => rl.Color{ .r = 200, .g = 200, .b = 200, .a = 255 }, //gris claro
    };
    if (side) { //si es cierto lado de la pared, se hace mas oscuro para dar efecto de sombra
        
        // (se ensancha a u16 antes de multiplicar para no desbordar el u8)
        return rl.Color{
            .r = @intCast(@as(u16, base.r) * 7 / 10),
            .g = @intCast(@as(u16, base.g) * 7 / 10),
            .b = @intCast(@as(u16, base.b) * 7 / 10),
            .a = 255,
        };
    }
    return base; // si no es el lado, se devuelve el color base
}
