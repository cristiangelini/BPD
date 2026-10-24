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

## Hecho así
- **Paso 1 (24/10):** TrafficQueue tiene la variante `clown_convoy` (un auto cada 4,5 s, paciencia normal): cada
  QueueCar es el autito de payasos de 2 m, con un payaso al volante, la patente "PAYASO 1" y un baúl chico. Se prueba
  con `godot --path . -- --place=traffic --traffic=clown_convoy`. Las pistas siguen siendo las de Hora pico hasta el
  paso 3.
- **Paso 2 (24/10):** el autito tiene puerta del lado del conductor (TrunkLid con `side`), se abre tirando hacia
  afuera. Salen de 3 a 6 payasos (por la patente, igual en todas las PC), el conductor primero, y se alejan de 2,5 a
  5 m haciendo malabares (ConvoyClown, 18 kg, uno solo lo carga). Llevado o empujado a menos de 1 m de la puerta, el
  payaso vuelve a entrar. Con payasos afuera el auto no se mueve, no pasa con la barrera y no se cuela; cada payaso
  suelto suma 0,4 por segundo a la paciencia.
- **Paso 3 (24/10):** WantedPlan con `convoy` saca las 3 pistas de ConvoyTraits del conductor: peluca (5 colores),
  nariz (3), guantes (3) y bocina (4 sonidos). Se ven en el payaso al volante y en el conductor cuando baja; los otros
  payasos se visten al azar por la patente. Cada autito toca su bocina al llegar y cada 9 s en la fila. El comisario
  cuenta la historia de la caja fuerte del director.
- **Paso 4 (24/10):** E al conductor (afuera o por la ventanilla) da la licencia, que dice cómo es la foto sin
  maquillaje: con o sin anteojos. Con la esponja (en la vereda, junto a los conos) y E tres veces se le saca el
  maquillaje y se ven sus anteojos, si tiene. El buscado lleva una licencia ajena (la foto no coincide) y la caja
  fuerte del director en el baúl; los otros baúles traen globos (5 de 10), tortas de crema (3) o una caja fuerte de
  cartón (2). Los otros payasos dicen que no manejan.
- **Paso 5 (24/10):** las esposas sobre el conductor afuera del auto lo detienen ahí mismo y los otros payasos se suben
  solos; esposar a otro payaso no hace nada ("yo no manejo"). El buscado sale como ChaseSuspect payaso y se lo escolta
  al patrullero (500, cuota propia); un inocente suma denuncia y se va. Si el autito buscado pasa el control, huye
  como el del circo soltando muñecos inflables. En "Jugar", el control de tránsito sale mitad Hora pico y mitad
  Caravana por la semilla; en la campaña cuenta como `traffic_clown_convoy`.
- **Paso 6 (24/10):** online, los payasos del anfitrión salen en todas las PC (PropSync, con el mismo nombre, ropa y
  auto), vuelven a entrar en todas, y la puerta abierta desde un invitado se abre en el anfitrión. La cara limpia, el
  asiento vacío del buscado y el autito que huye llegan con el caso (CaseSync). Las dos PC sacan la misma variante
  por la semilla.
