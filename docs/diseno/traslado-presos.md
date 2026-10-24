# BPD · Cárcel: traslado de presos (24/10)

Segunda variante de la cárcel ([casos.md](casos.md), punto 6, variante 2). Cristian la eligió en la tarjeta del 24/10.
Cristian respondió las 3 preguntas (decisión 105). Los números son **(propuesta)** hasta probarlos jugando.

## La idea
El juez mandó 8 presos a la cárcel de la ciudad y el bus de traslado lo llevan los novatos. Los presos van esposados a
sus asientos, pero cada uno tiene su plan para bajarse en el camino: pedir el baño, hacerse el enfermo, abrir las
esposas con una cuchara o saltar por la ventana en un semáforo. El chiste cooperativo: uno maneja el bus, que es
enorme y dobla mal, y los otros tres van parados en el pasillo vigilando, sentando a los presos con las manos y
tapando las ventanas mientras el bus se sacude.

## Cómo es el caso
1. **El aviso:** el comisario, en su oficina: "Novatos, hay que llevar a 8 presos a la cárcel en el bus. Son 8 al
   salir y tienen que ser 8 al llegar. Y no paren en ninguna panadería".
2. **El bus:** un bus de traslado viejo, con rejas en las ventanas (algunas flojas), 8 asientos de presos con argollas
   y el pasillo en el medio. Espera en el estacionamiento de la comisaría con los presos ya sentados. Se maneja como el
   patrullero, pero es más lento, más largo y dobla más abierto.
3. **El viaje:** la ruta va de la comisaría a la cárcel (cuadra 5, 2) por la ciudad, con semáforos y esquinas. Unos
   3 a 4 minutos sin desvíos.
4. **Los presos:** cada uno tiene un **plan de fuga** que se llena de a poco cuando ningún policía lo mira, y más
   rápido cuando el bus frena o dobla fuerte. Al llenarse, intenta su truco. Si un policía lo mira de cerca, el plan
   baja.
5. **Los trucos** (cada preso tiene uno, al azar por semilla):
   - **La cuchara:** se abre las esposas y se para en el pasillo. Hay que sentarlo con las manos y volver a esposarlo.
   - **El baño:** grita que se hace encima. Si el bus no frena en una estación de servicio, se enoja y contagia a los
     demás (se les llena el plan más rápido).
   - **El enfermo:** se tira al piso del pasillo. Si un policía se agacha a ayudarlo, sale corriendo hacia la puerta.
   - **La ventana floja:** empuja la reja de su ventana. Si el bus está parado (semáforo, choque), salta afuera.
   - **El cantante:** canta y hace dormir al policía más cercano (como el guardia de la fuga, pero al revés).
   - **El cómplice:** un auto lo sigue y, en un semáforo, le pasa una lima por la ventana.
6. **Si se escapa uno:** sale corriendo por la vereda y arranca la persecución a pie (`ChaseCase.begin`, como El Oso).
   Mientras tanto, el bus queda parado con los otros 7 adentro, que aprovechan. Atrapado, se lo vuelve a subir al bus
   esposado.
7. **Se gana** al entrar al patio de la cárcel con el bus y contar a los presos en el portón (la cuenta, preso por
   preso, la hace el carcelero). Sueldo de 600, 75 menos por cada preso que falte y 50 menos por cada choque fuerte del
   bus. Cuota propia de 400, como el motín.
8. **Se pierde** si se escapan 4 o más (propuesta) o si el bus queda volcado.

## Lo que se reusa
- La cárcel y su portón, los presos con su modelo y las esposas (`PrisonInmate`, `Handcuffs`), la mirada del guardia de
  la fuga (`NightGuard.sees`) al revés para el plan de fuga, y la persecución a pie embebida (`ChaseCase.begin`).
- El manejo del patrullero (`PatrolCar`), con otros números para el bus; los semáforos y las esquinas de la ciudad
  (`ChaseRoute`, el tráfico del control de tránsito).
- Lo nuevo: el bus manejable con pasillo y asientos, el plan de fuga, los 6 trucos y la cuenta en el portón.

## El orden para hacerlo (un PR chico por paso)
1. El bus: modelo, manejo y adentro (asientos, pasillo, ventanas con rejas), en el estacionamiento de la comisaría.
2. Los presos sentados y esposados, el plan de fuga y la mirada de los policías.
3. Los trucos, de a dos por PR (cuchara y baño; enfermo y ventana; cantante y cómplice).
4. La fuga a pie y volver a subirlo.
5. El final: la cuenta en el portón, sueldo, cuota, perder, el aviso del comisario y el sorteo de Jugar.
6. Online.

## Preguntas para Cristian
1. **¿Maneja el bus un policía** (como el patrullero, y los otros tres van vigilando adentro), o lo maneja un chofer
   NPC y los 4 vigilan? Recomendado: un policía, así uno sufre manejando el bus y los otros sufren adentro.
2. **¿Salen de la comisaría** (el bus espera en el estacionamiento con los presos), o de un juzgado nuevo en la ciudad?
   Recomendado: de la comisaría, así no hace falta otro lugar y el comisario los despide.
3. **¿Se pierde con 4 escapados**, o el caso nunca se pierde y solo baja el sueldo por cada preso que falta?
   Recomendado: se pierde con 4, así cada fuga importa.

## Respuestas de Cristian (24/10, decisión 105)
1. Maneja un policía; los otros tres vigilan adentro.
2. Salen de la comisaría: el bus espera en el estacionamiento con los presos.
3. Con 4 presos escapados el caso se pierde.

## Hecho así
- **Paso 1 (el bus):** `PrisonBus` (`scenes/vehicles/prison_bus.tscn`, modelo `prison_bus`) es un `PatrolCar` más grande: 10 m de largo, 4000 kg, hasta 40 km/h (también en la autopista) y dobla más abierto. Adentro: el asiento del chofer adelante a la izquierda, una reja detrás de la cabina con un hueco para el pasillo, 4 filas de 2 asientos de presos con su argolla y las ventanas con rejas. E junto a la puerta de adelante (a la derecha) o la de atrás (al final del pasillo) sube o baja; E junto al asiento del chofer lo maneja y otra E lo para en la cabina. Los que van parados caminan por el pasillo y se mueven con el bus; un frenazo, un arranque o una curva fuerte (más de 5 m/s²) los empuja para el otro lado (señal `lurched`, para el plan de fuga del paso 2). El caso es una variante de la cárcel (`PrisonLevel.variant = "transfer"`, `scenes/levels/prisoner_transfer.tscn`, `--place=transfer`): el bus espera en la calle de la comisaría con las puertas hacia la vereda y los policías arrancan en la sala de guardia. Capturas en `/mnt/project-files/traslado/paso1-*.png` y `prison_bus.png`.
- **Paso 2 (los presos y su plan de fuga):** `TransferPlan` sienta 8 presos (`BusInmate`, el preso del motín) en los 8 asientos, esposados a la argolla y como hijos del bus para que vayan con él. Cada uno tiene un plan de fuga de 0 a 100 que arranca entre 0 y 30 según la semilla. No se mueve hasta que el bus sale de la comisaría; después sube 2,5 por segundo mientras nadie lo mira y baja 10 por segundo mientras un policía parado en el bus lo mira de cerca (a menos de 3,5 m, en un cono de 60° y sin nada en el medio). El chofer mira la calle, no a los presos. Cada frenazo o curva fuerte le suma 8 de golpe a los que nadie mira. Con menos de 4 policías se llena más lento (con uno solo, a un cuarto). A los 50 se ve "..." sobre su cabeza, a los 80 un "!" rojo y en 100 avisa ("Esta es la mía.") y queda listo para su truco (`plan_ready`, paso 3). Medido: un guardia en la puerta de atrás mira solo la última fila. Captura en `/mnt/project-files/traslado/paso2-presos.png`.
- **Paso 3a (la cuchara y el baño):** `TransferTricks` le da un truco a cada preso con la semilla, de modo que salen todos antes de repetir. **La cuchara:** con el plan lleno se abre las esposas y se para en el pasillo junto a su asiento ("¡Ja! Con una cuchara se abre todo."). Si nadie lo sienta en 8 s, camina por el pasillo hasta la puerta más cercana y se queda ahí (`at_door`; el paso 4 lo hace saltar). Un policía parado en el pasillo delante de él lo frena. E, o las esposas, lo sientan y lo vuelven a encadenar, y su plan arranca de 0. **El baño:** grita que se hace encima y a los policías les aparece "Un preso necesita el baño: frena en la estación de servicio". Si el bus para 4 s junto a la estación de servicio nueva de la ciudad (cuadra (4, 2), lado sur, con dos surtidores y un techo rojo) antes de 40 s, se calma. Si no, se enoja (vapor rojo) y contagia: el plan de los demás se llena un 50% más rápido por cada preso enojado (`TransferPlan.contagion`). Capturas en `/mnt/project-files/traslado/paso3-cuchara.png` y `paso3-estacion.png`.
- **Paso 3b (el enfermo y la ventana floja):** **el enfermo** se tira en el pasillo a lo ancho ("¡Ay, ay! ¡Me muero! ¡Ayúdenme!"). Si un policía se agacha a menos de 1,6 m para ayudarlo, salta y corre a la puerta a 3 m/s ("¡Ja! ¡Caíste!"); E parado lo sienta y lo encadena. Si nadie hace nada en 15 s, se levanta y se va caminando a la puerta. **La ventana floja:** empuja la reja de su ventana 6 s sin moverse del asiento ("*Ñiiic, ñiiic*"); E lo frena ("E: apretar la reja") y su plan vuelve a 0. Si la reja cede, en cuanto el bus se para (semáforo, choque o en la comisaría) salta por la ventana a la vereda (`went_out`, para el paso 4). Los presos del bus son un poco más chicos que los del comedor (85%) y se sientan a 0,9 m del medio, para que no se salgan por la pared y un policía pase por el pasillo. Capturas en `/mnt/project-files/traslado/paso3-enfermo.png` y `paso3-ventana.png`.
- **Paso 3c (el cantante y el cómplice):** **el cantante** le canta una canción de cuna 5 s al policía parado más cercano a menos de 4 m ("La la laaa... duérmete, oficial..."). Si sigue cerca al terminar, el policía se duerme parado 10 s: no se mueve y no mira a nadie. E le tapa la boca ("E: taparle la boca"). **El cómplice:** aparece un auto oscuro (`AccompliceCar`, el modelo del auto de la fuga) 14 m detrás del bus y lo sigue por el mismo camino que hizo el bus, sin atravesar casas. A los policías les avisa "Un auto sigue al bus. Si paras, le pasan algo a un preso por la ventana". Si el bus se queda parado 1,5 s, el auto se pone junto a la ventana del preso, le pasa una lima y se va. Con la lima el preso corta la reja en 3 s (E lo frena) y salta como con la ventana floja. Si el bus no para en 60 s, el auto se rinde y el plan del preso vuelve a 0. El auto es solo de mirar: no choca. Con esto están los 6 trucos. Captura en `/mnt/project-files/traslado/paso3-complice.png`.
- **Paso 4 (la fuga a pie y volver a subirlo):** el preso suelto que llega a una puerta se baja en cuanto el bus se para ("¡La puerta estaba abierta! ¡Adiós, oficiales!"); los de la ventana saltan como antes. Afuera sale corriendo por la vereda arrastrando una bola con cadena (modelo `ball_and_chain`, 11 km/h) y arranca la persecución a pie de siempre (`TransferEscape`, `ChaseCase.begin` con `SuspectCar.INMATE_ON_FOOT`). El bus queda donde está, con los otros adentro llenando su plan. Atrapado y esposado, se lo lleva caminando hasta el bus (cualquier parte de la carrocería) y vuelve a su propio asiento, encadenado y con el plan en 0. Si se escapa, cuenta como escapado (`TransferEscape.escaped`, para el paso 5). Una persecución por vez: si se baja otro mientras tanto, espera quieto y sale corriendo cuando termina la primera. Captura en `/mnt/project-files/traslado/paso4-fuga.png`.
- **Paso 5 (el final):** `TransferCase`. El bus queda cerrado hasta hablar con el comisario ("Son 8 al salir y tienen que ser 8 al llegar. Y no paren en ninguna panadería."); Q abre la planilla con los presos en el bus, los escapados (con 4 se pierde) y los choques fuertes del bus (los mismos que multan en la persecución, `ChaseDamages`). Con el bus parado en el patio de la cárcel, el carcelero (junto al portón) cuenta a los presos de a uno cada 0,8 s ("¡1!", "¡2!"...) y termina con "Están todos" o "Faltan N". Si alguien anda suelto, espera a que lo traigan. Mientras cuenta, los presos ya no planean nada. Sueldo 600, 75 menos por cada preso que falta y 50 menos por cada choque fuerte; cuota 400. Se pierde con 4 escapados o con el bus volcado 3 s. En el sorteo de Jugar, la mitad de los casos de la cárcel son el motín y la mitad el traslado (`PlaceDraw.PRISONS`). Captura en `/mnt/project-files/traslado/paso5-cuenta.png`.
- **Paso 6 (online):** el host decide todo y los invitados lo siguen. El bus va como el patrullero (lo simula el host y el chofer manda las teclas). Los presos van con su plan, su "..." o "!" y lo que están haciendo (sueltos, en el piso, empujando la reja, cantando, afuera), así que cualquier policía los puede sentar o frenar con E desde su PC. El auto del cómplice también se ve en todas las PC. Si se escapa uno, la persecución arranca en todas las PC; atrapado, vuelve a su asiento en todas, y si se escapa cuenta para todos. La cuenta del carcelero y el final se ven igual en todas las PC. Un frenazo o una curva fuerte empujan al policía de cada jugador en su propia PC, y la canción de cuna duerme al policía del jugador que estaba cerca, en su PC. Probado con un host y un invitado en la misma PC.
