# BPD · Escala, cámara y movimiento

Valores base del juego. Todas las constantes de código salen de acá y viven en un solo archivo (`scripts/game_scale.gd`). No se cambian sin una decisión de Cristian. Los marcados con **(propuesta)** son míos y se confirman en la primera prueba jugando.

1 unidad de Godot = 1 metro.

## Policía
| Qué | Valor |
|---|---|
| Altura | 1,55 m, cuerpo pera de 1 m de ancho (cápsula de radio 0,5 m) |
| Altura de los ojos (cámara) | 1,35 m |
| Caminar | 4,0 m/s |
| Correr (Shift) | 6,5 m/s, con 6 s de aguante y recuperación en 4 s. Si se agota, no se vuelve a correr hasta recuperar la mitad **(propuesta)** |
| Agachado (Ctrl) | 2,0 m/s, altura de 1,1 m |
| Salto | 1,0 m de alto |
| Caída que desmaya | más de 4 m |

## Cámara
| Qué | Valor |
|---|---|
| Vista | primera persona (decisión 11) |
| Campo de visión | 80°, ajustable entre 70° y 100° en Opciones **(propuesta)** |
| Balanceo al caminar | suave, se puede apagar en Opciones |

## Agarrar y cargar
| Qué | Valor |
|---|---|
| Alcance para agarrar | 2,5 m |
| Fuerza de un policía | carga solo hasta 25 kg |
| Objetos pesados | de más de 25 kg hace falta que agarren varios (las fuerzas se suman) |
| Distancia del objeto agarrado | la rueda del mouse lo acerca o lo aleja entre 1 y 2,5 m |
| Tirar (clic derecho) | impulso de 8 m/s para un objeto de 1 kg (menos cuanto más pesa) |

## Edificios
| Qué | Valor |
|---|---|
| Puerta | 1,2 × 2,1 m |
| Pasillo | 1,2 m de ancho como mínimo |
| Altura de un piso | 2,7 m |
| Escalera | 0,18 m por escalón, 1,0 m de ancho |

## Cambios
- 19/10: el policía pasó de 1,80 × 0,7 m a 1,55 × 1 m (ojos a 1,35 m) y las puertas de 0,9 a 1,2 m, para que el cuerpo pera (decisión 72) coincida con lo que choca. Lo eligió Cristian (decisión 73).
