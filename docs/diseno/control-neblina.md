# BPD · Control de tránsito: Neblina (propuesta, 25/10)

Octava variante del control de tránsito ([control-transito.md](control-transito.md), variante 7;
[casos.md](casos.md), punto 8.7). Reusa el control de "Hora pico" y lo de las otras variantes
([control-payasos.md](control-payasos.md), [control-frutas.md](control-frutas.md),
[control-auto-lleno.md](control-auto-lleno.md), [control-auto-fantasma.md](control-auto-fantasma.md),
[control-boda.md](control-boda.md), [control-carrera.md](control-carrera.md)): conos, barrera, la fila y su
medidor, papeles, baúl, denuncias, escolta, el sorteo por semilla y la persecución. La linterna es la del cinturón y
la niebla es la de la lluvia de la persecución (ChaseWeather), más espesa. Los números son **(propuesta)** hasta
probarlos jugando.

## La historia
El comisario: "¡Novatos! Alguien se robó la lámpara del faro del puerto y desde entonces la ciudad está tapada de
niebla. El ladrón, La Bruma, va a salir de la ciudad esta noche por la avenida. No se ve nada, así que van a tener
que usar las orejas y la linterna. Y no me choquen a nadie."

## Cómo es
1. **Niebla espesa:** se ve hasta unos 15 m. Los autos llegan con los **faros prendidos**: de lejos se ven solo dos
   luces que crecen en la niebla y el **color del auto se ve recién a 8 m**.
2. **Los autos aparecen de golpe:** sin aviso llegan rápido y **frenan tarde**: se llevan puestos los conos y si no
   frenan a tiempo se pasan el control (baja la paciencia de la fila, como un auto que se cuela). Para que frenen hay
   que **avisarles**: un policía en la esquina de atrás, metido en la niebla, **apuntándoles con la linterna** (F),
   o los **conos con luz** del baúl del patrullero (4, parpadean). Con aviso, el auto frena despacio y hace la fila
   como siempre.
3. **La sirena de niebla:** está en el baúl del patrullero (se agarra como la linterna). Con E suena "¡BUUUUH!" y
   **todos los autos que están en la niebla contestan con su bocina**: sobre cada auto se ve el globito con su
   bocina ("¡Mec-mec!", "¡Tururú!", "¡Fiu-fiu!", "¡Piiip!", "¡Cuac!", 10+ con tr()), aunque el auto no se vea.
   Se puede tocar cada 10 s.
4. **La Bruma** va en uno de los autos de la fila. La radio da una pista cada 60 s, como en Hora pico: el **color de
   los faros** (blancos, amarillos, azulados), **su bocina**, el **faro roto** (el izquierdo, el derecho o ninguno)
   y el **color del auto**. Dos o tres autos se le parecen: se pueden confundir de lejos.
5. Se para el auto, papeles y baúl como siempre: en el baúl de La Bruma está **la lámpara del faro**, enorme, que
   ilumina la niebla alrededor.
6. **Se gana** deteniendo a La Bruma y llevándolo al patrullero: 500, misma cuota que Hora pico. La lámpara del faro
   en el baúl del patrullero suma 100. Detener a un inocente es denuncia y a la segunda se pierde, como siempre.
7. **Se pierde** si La Bruma pasa el control: se escapa por la ciudad con la niebla (persecución). En la niebla el
   patrullero lo ve solo de cerca, pero La Bruma **toca la bocina en cada esquina** (no puede con su genio) y el
   globito de su bocina se ve a través de la niebla. Si se escapa también ahí, se pierde el caso.
8. En "Jugar", el control de tránsito sale un octavo cada variante: Hora pico, Caravana, Camión de frutas, Auto
   lleno, Auto fantasma, Boda, Carrera y Neblina.

## Lo nuevo
- La niebla del control y los faros de los autos (variante `fog`).
- Los autos que frenan tarde, los conos con luz y el aviso con la linterna.
- La sirena de niebla y las bocinas que contestan.
- El plan: el auto de La Bruma, sus pistas (faros, bocina, faro roto, color) y los parecidos (sobre WantedPlan).
- La lámpara del faro como prueba (+100 en el baúl).
- La persecución en la niebla con la bocina en las esquinas.

## Preguntas para Cristian
1. **¿Sin aviso (linterna o conos con luz) los autos frenan tarde y se pasan el control?**
   Recomiendo que sí: obliga a repartirse, uno en la niebla con la linterna y los otros en la barrera.
2. **¿La sirena de niebla hace contestar a todos los autos con su bocina, y una de las pistas es la bocina?**
   Recomiendo que sí: se encuentra a La Bruma con las orejas antes de verlo, que es lo distinto de esta variante.
3. **¿El color del auto se ve recién a 8 m, y de lejos solo los faros?**
   Recomiendo que sí: las pistas de los faros sirven de lejos y la del color solo en la barrera.

## El orden para hacerlo (un PR chico por paso, apilados sobre la Carrera)
1. La niebla del control y los faros (variante `fog`).
2. Llegar rápido y frenar tarde; los conos con luz y el aviso con la linterna.
3. La sirena de niebla y las bocinas.
4. El plan: La Bruma, sus pistas, la radio y los parecidos.
5. Detener, escoltar, la lámpara +100, sueldo, el escape en la niebla y el sorteo en "Jugar".
6. Online.

## Online
Como las otras variantes: el anfitrión decide la fila, quién es La Bruma y cuándo frena cada auto; la sirena y los
conos con luz son objetos que se agarran (PropSync), y cada PC ve la misma niebla, los mismos globitos de bocina y
el final ([online.md](online.md)).
