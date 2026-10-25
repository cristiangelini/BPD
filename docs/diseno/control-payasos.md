# BPD · Control de tránsito: Caravana de payasos (propuesta, 24/10)

Segunda variante del control de tránsito ([control-transito.md](control-transito.md), variante 2;
[casos.md](casos.md), punto 8.2). Reusa todo el control de "Hora pico" (conos, barrera, la fila y su medidor,
papeles, baúl, denuncias, escolta y persecución) y lo del circo ([escena-circo.md](escena-circo.md)): el autito de
payasos, los payasos con sus partes y la esponja. Los números son **(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! El circo se muda esta noche y pasa toda la caravana por la esquina. Uno de los payasos se
lleva escondida la caja fuerte del director. Todos los autitos son iguales, así que miren bien al que maneja."

## Cómo es
1. Llegan 12 a 18 **autitos de payasos idénticos** (el modelo `clown_car` del circo, todos del mismo color y con la
   misma patente pintada: "PAYASO 1"). El color y la patente no sirven.
2. Las pistas son **del conductor**, de los rasgos del payaso que ya existen (ClownTraits): color de peluca, tipo de
   nariz (roja, con bocina, de foco), zapatos (gigantes o enormes), maquillaje (lágrima, estrella, sonrisa) y la
   bocina del autito (cada uno suena distinto). El comisario da una y la radio otra cada 60 s, como en Hora pico.
3. **La puerta del autito** se abre con las manos, como el baúl. Al abrirla salen en fila de 3 a 6 payasos (el chiste
   de siempre) y se dispersan haciendo malabares. Solo uno es el conductor: es el que tiene las llaves con el pompón.
4. **Volver a meterlos:** el autito no arranca hasta que vuelven a estar todos adentro, agarrándolos con las manos
   o empujándolos. Mientras tanto la fila se impacienta. Payasos sueltos en la calle suman paciencia más rápido.
5. **La licencia** del conductor tiene foto sin maquillaje, así que de entrada no sirve: pasándole la esponja del
   circo a la cara se ve si coincide. El baúl de los autitos tiene globos, tortas de crema o la caja fuerte.
6. Detener a un payaso inocente suma denuncia y al segundo se pierde, como en Hora pico.
7. **Se gana** deteniendo al payaso de la caja fuerte y llevándolo al patrullero: 500, misma cuota que Hora pico.
   **Se pierde** si pasa el control: se escapa en el autito soltando muñecos inflables, como el final del circo
   (ChaseCase con CLOWN_CAR y ChaseDrops). Si se escapa también ahí, se pierde el caso.
8. En "Jugar", el control de tránsito sale mitad Hora pico y mitad Caravana, por la semilla.

## Lo nuevo
- `ConvoyPlan` (como WantedPlan): sortea autos, conductor buscado, 3 pistas de payaso y 2 o 3 parecidos.
- La puerta del autito y los payasos que salen y vuelven a entrar (ConvoyClown, sobre CircusClown).
- La licencia con foto que se compara después de la esponja.
- Bocinas distintas por autito (10 sonidos procedurales).
- Frases nuevas de conductores payasos (12, con tr()).

## Preguntas para Cristian
1. **¿Del autito bajan muchos payasos y hay que volver a meterlos a todos antes de que arranque?**
   Recomiendo que sí: de 3 a 6 por auto, es el chiste cooperativo (uno revisa, otros arrean payasos).
2. **¿La foto de la licencia es sin maquillaje y hay que pasarle la esponja para compararla?**
   Recomiendo que sí, porque reusa la esponja del circo y suma una cosa más para hacer con las manos.
3. **Si el payaso se escapa, ¿persecución en el autito soltando muñecos, como el circo?**
   Recomiendo que sí, reusando el final del circo tal cual.

## Respuestas de Cristian (24/10)
1. Sí: bajan de 3 a 6 payasos por autito y hay que volver a meterlos a todos antes de que arranque.
2. Sí: la licencia tiene foto sin maquillaje y se compara después de pasarle la esponja.
3. Sí: el que se escapa huye en el autito soltando muñecos, como el final del circo.

## El orden para hacerlo (un PR chico por paso, apilados sobre el circo)
1. La caravana: autitos idénticos en la fila y la variante "clown_convoy" en TrafficQueue.
2. La puerta y los payasos que salen y vuelven a entrar.
3. ConvoyPlan: pistas del conductor, radio y bocinas.
4. Licencia con foto y esponja, baúles de payaso.
5. Final: detener, escapar en el autito, sueldo y sorteo en "Jugar".
6. Online.

## Online
Como Hora pico: el anfitrión decide la fila, los payasos que salen y el buscado; cada PC ve los mismos autitos,
payasos, puertas, licencias limpias y el final ([online.md](online.md)).
