# BPD · Control de tránsito: Desfile (Cristian, 26/10: sí a las 3 preguntas)

Décima variante del control de tránsito ([control-transito.md](control-transito.md), variante 8;
[casos.md](casos.md), punto 8.8). Reusa el control de "Hora pico" y lo de las otras variantes
([control-payasos.md](control-payasos.md), [control-frutas.md](control-frutas.md),
[control-auto-lleno.md](control-auto-lleno.md), [control-auto-fantasma.md](control-auto-fantasma.md),
[control-boda.md](control-boda.md), [control-carrera.md](control-carrera.md), [control-neblina.md](control-neblina.md),
[control-circo.md](control-circo.md)): conos, barrera, la fila y su medidor, papeles, baúl, denuncias, escolta, el
sorteo por semilla y la persecución. Los números son **(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! Alguien robó la corona de la Reina del Desfile y el desfile de carrozas sale justo por
nuestra calle. El ladrón, El Antifaz, se subió a una carroza disfrazado de bailarín. Revisen las carrozas, pero rápido:
si paran la música, la gente se enoja."

## Cómo es
1. **Las carrozas:** por el control pasan 8 a 12 **carrozas** lentas (un camión tapado de cartón pintado con un
   tema: **dragón, barco pirata, torta gigante, castillo, volcán, ballena o cohete**) mezcladas con 4 a 6 autos comunes
   que quedaron atrapados en el desfile. Arriba de cada carroza bailan 3 a 5 **bailarines con antifaz**, y cada
   carroza lleva un cartel con su **número**.
2. **La música:** cada carroza toca su canción mientras avanza. Si una carroza queda **parada en el control más de
   20 s**, se corta la música, el público abuchea y la fila se impacienta el doble hasta que la carroza sigue.
3. **El baile:** con E en la carroza se le pide a los bailarines que hagan **el paso de su carroza** (cada tema
   tiene el suyo: el dragón mueve los brazos como alas, el barco rema, la torta gira...). Todos lo hacen igual y
   **El Antifaz hace otro paso** (globito con una excusa de persona, 10+ frases con tr()). Hay 1 o 2 bailarines
   torpes en otras carrozas que a veces se equivocan **un poco** (llegan tarde al paso, no hacen otro), así que hay
   que mirar bien.
4. **Bajar a un bailarín:** con E en un bailarín se lo hace bajar. El Antifaz se puede esposar y llevar al
   patrullero. Bajar a un bailarín de verdad es **denuncia** (la Reina del Desfile se queja), como detener a un
   inocente.
5. **Las pistas:** la radio da una pista cada 60 s: el **tema de la carroza**, el **color del antifaz**, lo que
   tiene en la mano (**pompones, maracas, abanico o cinta**) y el **último número del cartel**. Hay 2 o 3
   bailarines de verdad que se le parecen.
6. **Se gana** deteniendo a El Antifaz y llevándolo al patrullero: 500, misma cuota que Hora pico. La **corona**
   la tiene escondida en el disfraz: al esposarlo se le cae al piso, y en el baúl del patrullero suma 100. A la segunda denuncia se pierde, como siempre.
7. **Se pierde** si la carroza de El Antifaz pasa el control: se escapa por la ciudad (persecución, la carroza es
   lenta pero ancha y tapa la calle) y **en cada esquina tira un cañonazo de confeti** que tapa la vista del que
   maneja 3 s. Si se escapa también ahí, se pierde el caso.
8. En "Jugar", el control de tránsito sale un décimo cada variante: Hora pico, Caravana, Camión de frutas, Auto
   lleno, Auto fantasma, Boda, Carrera, Neblina, Mudanza del circo y Desfile.

## Lo nuevo
- Las carrozas con su tema, cartel y bailarines (variante `parade`).
- La música que se corta y el abucheo si una carroza queda parada.
- El paso de cada carroza, el paso equivocado de El Antifaz y los bailarines torpes.
- Bajar a un bailarín de la carroza.
- El plan: El Antifaz, sus pistas (tema, antifaz, lo que tiene en la mano, número) y los parecidos (sobre WantedPlan).
- La corona como prueba (+100 en el baúl).
- La persecución de la carroza con confeti en las esquinas.

## Preguntas para Cristian (respondidas el 26/10: sí a las 3)
1. **¿El ladrón es un bailarín con antifaz arriba de una carroza que se delata porque hace otro paso cuando se le
   pide el baile (y hay bailarines torpes que confunden)?**
   Recomiendo que sí: obliga a mirar a todos los bailarines a la vez, y en grupo cada uno mira a uno.
2. **¿Una carroza parada más de 20 s corta la música y la fila se impacienta el doble?**
   Recomiendo que sí: es lo propio del desfile, no se puede revisar todo con calma.
3. **¿Si se escapa, tira confeti en las esquinas que tapa la vista del que maneja 3 s?**
   Recomiendo que sí: es lo propio de esta persecución, como las cáscaras del circo.

## El orden para hacerlo (un PR chico por paso, apilados sobre la Mudanza del circo)
1. Las carrozas, sus temas, el cartel y los bailarines (variante `parade`).
2. La música y el abucheo si una carroza queda parada.
3. El baile: el paso de cada carroza, el de El Antifaz y los torpes; bajar a un bailarín.
4. El plan: El Antifaz, sus pistas, la radio y los parecidos.
5. Detener, escoltar, la corona +100, sueldo, el escape con confeti y el sorteo en "Jugar".
6. Online.

## Online
Como las otras variantes: el anfitrión decide la fila, quién es El Antifaz, qué paso hace cada bailarín y cuándo se
corta la música; cada PC ve los mismos pasos, globitos y el final ([online.md](online.md)).
