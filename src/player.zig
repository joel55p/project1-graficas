const std = @import("std");  //librería estándar de Zig
const rl = @import("raylib_c.zig").raylib;  //raylib para zig
const map = @import("map.zig"); // se importa el mundo

//aqui se def el jugador, su posición, ángulo y velocidad de movimiento y rotación
pub const Player = struct {

    x: f32, //posicion en x coordenas de mundo
    y: f32, //posicion en y coordenas de mundo
    angle: f32, //hacia donde ve el player es angulo en rad

    pitch: f32 = 0, //campo nuevo  que representa la inclinación de la cámara del jugador, es decir, si está mirando hacia arriba o hacia abajo. Se mide en píxeles y se usa para ajustar la posición del horizonte en la pantalla.

    move_speed: f32 = 2.5, // unidades de mapa por segundo
    rot_speed: f32 = 2.2, // radianes por segundo
    mouse_sensitivity: f32 = 0.003, // radianes por pixel de mouse
    pitch_sensitivity: f32 = 1.0,  // que tan sensible es el mov verticual del mouse 
    max_pitch: f32 = 220, //limite de cuanto se puede inclinar la vista 


    pub fn init(x: f32, y: f32, angle: f32) Player { //f32 porque es un float de 32 bits, se usa para coordenadas y angulos

        return Player{ .x = x, .y = y, .angle = angle }; //se inicializa el jugador con la posición y angulo dados
    }


    //funcion importante para no atravesar paredes
    fn try_move(self: *Player, dx: f32, dy: f32) void {
        const new_x = self.x + dx; // nueva posición en x del jugador
        if (!map.is_wall(map.at(@intFromFloat(new_x), @intFromFloat(self.y)))) { //si es diferente de pared, se mueve el jugador
            self.x = new_x; //se actualiza la posición en x del jugador
        }

        //igual se analiza la posicion en y, para que no atraviese paredes

        const new_y = self.y + dy;
        if (!map.is_wall(map.at(@intFromFloat(self.x), @intFromFloat(new_y)))) {
            self.y = new_y;
        }
    } //realmente esta funcion es importante ya que analiza por separado la posicion de movimiento del jugador



    //trigonometria para mover al jugador, se analiza si se presiona W o S para moverse hacia adelante o hacia atras, y A o D para rotar a la izquierda o derecha
    pub fn handle_input(self: *Player, dt: f32) void { //dt delta time, tiempo transcurrido desde ultimo frame

        //definicion de circulo unitario para calcular la direccion hacia donde se mueve el jugador, usando coseno y seno del angulo del jugador
        const forward_x = @cos(self.angle);
        const forward_y = @sin(self.angle);

        var move: f32 = 0; // si es 0 no se mueve
        if (rl.IsKeyDown(rl.KEY_W)) move += 1; //adelante
        if (rl.IsKeyDown(rl.KEY_S)) move -= 1; //atras

        if (move != 0) { //si no esta parado, se calcula la distancia a mover y se llama a try_move para mover al jugador
            const dist = move * self.move_speed * dt;  // vel x dt hace que se mueva a la misma velocidad sin importar el framerate
            self.try_move(forward_x * dist, forward_y * dist);
        }


        if (rl.IsKeyDown(rl.KEY_D)) self.angle += self.rot_speed * dt; //rotar a la derecha
        if (rl.IsKeyDown(rl.KEY_A)) self.angle -= self.rot_speed * dt; //rotar a la izquierda

        //solo horizontal
        const mouse_delta = rl.GetMouseDelta();
        self.angle += mouse_delta.x * self.mouse_sensitivity;

        //pero ahora tambien solo vertical
        self.pitch -= mouse_delta.y * self.pitch_sensitivity;

        //funcion que encierra un numero entre dos limites
        self.pitch = std.math.clamp(self.pitch, -self.max_pitch, self.max_pitch);
    } // en si se hace resta ya que el eje y del mouse es invertido, es decir, si muevo el mouse hacia arriba, el valor de y es negativo, por lo que se resta para que la vista suba
};