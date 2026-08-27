# Raycaster

Raycaster simple en Zig + raylib, para el curso de Gráficas por Computadora.

## Video

https://youtu.be/GldDfPv9euQ 

## Cómo correrlo

```bash
git clone https://github.com/joel55p/project1-graficas.git
cd project1-graficas
zig build run
```

Requiere Zig 0.16+. Necesitas conexión a internet la primera vez que compiles (descarga raylib-zig).

## Controles

| Tecla / Mouse | Acción |
|---|---|
| `W` / `S` | Avanzar / retroceder |
| `A` / `D` | Rotar izquierda / derecha |
| Mouse (eje X) | Rotar cámara |
| Mouse (eje Y) | Ver hacia arriba / abajo |
| `ENTER` | Empezar (en la pantalla de bienvenida) |
| `R` | Reiniciar (en la pantalla de éxito) |

## Qué implementa

- Raycasting con algoritmo DDA, con corrección de "ojo de pez".
- Colisión con paredes (no se pueden atravesar).
- 4 tipos de pared, cada uno con su color.
- Cámara con movimiento adelante/atrás, rotación horizontal (teclado y mouse) y vertical (pitch, mouse).
- Minimapa en la esquina superior izquierda.
- FPS visibles en pantalla.
- Música de fondo.
- Pantalla de bienvenida y pantalla de éxito.