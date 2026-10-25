# BPD · Control de tránsito: El auto fantasma (propuesta, 25/10)

Quinta variante del control de tránsito ([control-transito.md](control-transito.md), variante 9;
[casos.md](casos.md), punto 8.9). Reusa el control de "Hora pico" y lo de las otras variantes
([control-payasos.md](control-payasos.md), [control-frutas.md](control-frutas.md),
[control-auto-lleno.md](control-auto-lleno.md)): conos, barrera, la fila y su medidor, papeles, baúl, denuncias,
escolta, el sorteo por semilla y la persecución. Los números son **(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! El Titiritero, un ladrón de cajeros, ya no se sube a sus autos: los maneja con un control
remoto desde atrás, en otro auto. Si ven un auto sin nadie al volante, no lo persigan a él: busquen quién lo maneja."

## Cómo es
1. Llegan 12 a 16 autos de la ciudad, como en Hora pico, cada conductor con el codo en la ventanilla abierta. Uno es
   **el auto fantasma**: no tiene a nadie en la ventanilla, las ruedas de adelante giran solas y tiene una antenita
   con una luz roja en el techo. Llega entre los primeros 3 a 6 de la fila.
2. **El Titiritero** va en uno de los autos que vienen atrás (2 a 5 autos más atrás) con el control remoto escondido
   en las piernas. La radio da una pista de él cada 60 s (color de su auto, sombrero o anteojos, la patente), como en
   Hora pico.
3. **Las travesuras:** cada 15 a 25 s el auto fantasma hace algo solo: toca bocina, prende las luces, avanza y le pega a
   la barrera o retrocede y empuja al policía que está atrás. Abrirle el baúl lo hace escaparse 1,5 m.
4. **El tic:** cada vez que el auto fantasma hace una travesura, el Titiritero mueve los pulgares y asoma la antena del
   control por la ventana durante 2 s. Ahí está la pista buena: mirar la fila cuando el fantasma hace algo.
5. E al volante vacío del fantasma no da papeles: "No hay nadie... ¿hola?". Si un policía lo empuja o le pega, el
   Titiritero se asusta y hace una travesura enseguida (otro tic).
6. Detener a un conductor inocente suma denuncia y al segundo se pierde, como siempre.
7. **Se gana** deteniendo al Titiritero y llevándolo al patrullero: 500, misma cuota que Hora pico. Al esposarlo se
   le cae el control remoto; llevarlo al baúl del patrullero suma 100 (como los relojes del Camión de frutas).
8. **Se pierde** si el auto del Titiritero pasa el control: huye por la ciudad y el auto fantasma lo sigue y se cruza
   delante del patrullero en cada esquina. Si se escapa también ahí, se pierde el caso. El fantasma solo no se puede
   detener (no hay a quién esposar): si pasa el control, sigue de largo y no pasa nada.
9. En "Jugar", el control de tránsito sale un quinto cada variante: Hora pico, Caravana, Camión de frutas, Auto lleno
   y Auto fantasma.

## Lo nuevo
- `GhostCar`: los conductores en la ventanilla y el auto sin conductor con ruedas que giran solas, antenita y
  travesuras (bocina, luces, avanzar, retroceder, escaparse al abrirlo).
- El Titiritero con el control remoto y su tic (pulgares y antena).
- El plan: dónde va el fantasma, en qué auto va el Titiritero y sus pistas (sobre WantedPlan).
- El control remoto como prueba (+100 en el baúl).
- La persecución con el fantasma que se cruza en las esquinas (ChaseDrops).

## Preguntas para Cristian
1. **¿El auto fantasma se ve vacío desde el principio y lo difícil es encontrar quién lo maneja desde la fila?**
   Recomiendo que sí: el chiste es que el auto raro está a la vista y el culpable se esconde entre los normales.
2. **¿La pista buena es el tic: cuando el fantasma hace una travesura, el Titiritero asoma la antena 2 s?**
   Recomiendo que sí, así un policía provoca al fantasma (empujarlo, abrirle la puerta) y los otros miran la fila.
3. **¿El control remoto que se le cae al Titiritero vale 100 si se lleva al baúl del patrullero?**
   Recomiendo que sí, como los relojes del Camión de frutas: un premio extra para el que se acuerda.

## El orden para hacerlo (un PR chico por paso, apilados sobre el Auto lleno)
1. El auto fantasma en la fila: sin conductor, volante que gira, antenita (variante `ghost_car`).
2. Las travesuras del fantasma y el Titiritero con su tic.
3. El plan: dónde van el fantasma y el Titiritero, pistas y radio.
4. Detener, escoltar, el control remoto +100, sueldo.
5. El escape con el fantasma que se cruza y el sorteo en "Jugar".
6. Online.

## Online
Como las otras variantes: el anfitrión decide la fila, cuál es el fantasma, quién es el Titiritero y cuándo hace cada
travesura; cada PC ve los mismos autos, las mismas travesuras, el mismo tic y el final ([online.md](online.md)).
