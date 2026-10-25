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
