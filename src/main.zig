//mis 5 modulos
const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const map = @import("map.zig");
const player_mod = @import("player.zig");
const raycaster = @import("raycaster.zig");
const renderer = @import("renderer.zig"); 

//const de configuracion
const SCREEN_WIDTH = 960;
const SCREEN_HEIGHT = 600;
const NUM_RAYS = 320;
const FOV: f32 = std.math.pi / 3.0;

//estados con el enum

const State = enum { welcome, playing, success };

pub fn main() !void {
    //se arranca con la ventana y el audio
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Raycaster");
    defer rl.CloseWindow(); //cerrar ventana al final del programa
    rl.SetTargetFPS(60);

    //los 4 pasos para musica en raylib

    rl.InitAudioDevice(); //1. se inicia sistema audio
    defer rl.CloseAudioDevice();

    const music = rl.LoadMusicStream("music/marito.mp3"); //2. cargar el archivo a memoria
    defer rl.UnloadMusicStream(music);
    rl.SetMusicVolume(music, 0.4); //3. fijar el nivel de volumen
    rl.PlayMusicStream(music); //4. arrancar a sonar 


    //como zig no tiene un garbage collector, se usa un allocator para manejar memoria dinamica, en este caso se usa el DebugAllocator que es un allocator que imprime mensajes de debug cuando se asigna o libera memoria

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const hits = try allocator.alloc(raycaster.RayHit, NUM_RAYS);
    defer allocator.free(hits);


    //estado inicial
    var player = player_mod.Player.init(1.5, 1.5, 0.0); //viendo hacia la derecha ya que angulo es 0 arranca el game 
    var state: State = .welcome; //pantalla de bienvenida 

    //loop principal
    while (!rl.WindowShouldClose()) {
        const dt = rl.GetFrameTime();

        rl.UpdateMusicStream(music);

        switch (state) { //para actualizar
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

        switch (state) { //para dibujar  segun estado 
            .welcome => draw_welcome_screen(),
            .playing => {
                renderer.draw_scene(hits, SCREEN_WIDTH, SCREEN_HEIGHT, player.pitch);
                renderer.draw_minimap(&player, 8);
                renderer.draw_fps(SCREEN_WIDTH - 110, 10);
            },
            .success => draw_success_screen(),
        }
    }
}


// pantallas de texto para cada estado del juego
fn draw_welcome_screen() void {
    rl.ClearBackground(rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 });
    rl.DrawText("RAYCASTER", SCREEN_WIDTH / 2 - 160, SCREEN_HEIGHT / 2 - 80, 60, rl.RAYWHITE);
    rl.DrawText("Presiona ENTER para empezar", SCREEN_WIDTH / 2 - 180, SCREEN_HEIGHT / 2 + 10, 24, rl.LIGHTGRAY);
    rl.DrawText("W/S mover, A/D o mouse rotar, mouse Y para ver arriba/abajo", SCREEN_WIDTH / 2 - 280, SCREEN_HEIGHT / 2 + 45, 18, rl.GRAY);
}

fn draw_success_screen() void {
    rl.ClearBackground(rl.Color{ .r = 15, .g = 35, .b = 20, .a = 255 });
    rl.DrawText("NIVEL COMPLETADO", SCREEN_WIDTH / 2 - 240, SCREEN_HEIGHT / 2 - 60, 50, rl.GOLD);
    rl.DrawText("Presiona R para reiniciar", SCREEN_WIDTH / 2 - 160, SCREEN_HEIGHT / 2 + 20, 22, rl.RAYWHITE);
}