# BPD · Cárcel: motín en el comedor (23/10)

Décimo y último tipo de caso del catálogo ([casos.md](casos.md), punto 6) y la decisión 29. Cristian eligió el motín en
el comedor en la tarjeta del 23/10 y respondió las 3 preguntas (decisión 104). Los números son **(propuesta)** hasta probarlos jugando.

## La idea
La cárcel de la ciudad pide refuerzos: en el comedor empezó una guerra de comida y los guardias se escondieron en la
cocina. Los 4 novatos entran con bandejas como escudo a parar a 20 presos que se tiran puré, gelatina y pollo. El
chiste cooperativo: unos cubren con las bandejas, otros apagan a los más rabiosos con lo que encuentran y otro esposa a
los cabecillas mientras le llueve gelatina.

## La cárcel (lugar nuevo, sirve para los otros 9 casos de la cárcel)
Un lote grande y amurallado en el borde este de la ciudad (cuadra 5, 2, propuesta), con portón, patio, pabellón de
celdas y comedor. Para el motín se usa solo el comedor y el patio de entrada; el resto se cierra con rejas hasta que
otra variante lo necesite. Se llega en el patrullero, como al banco.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, motín en el comedor de la cárcel. Los guardias se encerraron en
   la cocina. Vayan y calmen a esos presos. Y no coman nada".
2. **El comedor:** 6 mesas largas con bancos, el mostrador de la comida, ollas de puré y bandejas de gelatina. Las
   mesas se pueden volcar con las manos para cubrirse (física, como los muebles del allanamiento).
3. **Los presos:** 20 con mameluco naranja (modelo nuevo de modelgen), de mesa en mesa. Cada uno tiene un **enojo** de
   0 a 100 que sube cuando le pega comida y baja con el tiempo si nadie lo molesta. Con enojo alto tira comida a los
   policías y a otros presos (que se enojan también: el motín se contagia).
4. **La comida:** puré, gelatina, pollo y yogur, objetos con física que vuelan en arco (como los huevos del político).
   Pegan y manchan; un policía con 5 manchas resbala y se cae. Se agarran en el aire y se pueden devolver.
5. **Calmar:** un policía que se acerca a un preso y lo mira, sin que le peguen comida, lo calma de a poco hablándole
   (E). Con enojo 0 el preso se sienta y deja de tirar. Esposarlo también lo calma (decisión 104). Las bandejas paran la
   comida si se sostienen delante.
6. **Los cabecillas:** 3 presos (al azar por semilla) con el enojo que no baja nunca; se los reconoce porque se suben a
   las mesas y gritan. Hay que esposarlos y llevarlos a la celda de castigo (escolta del allanamiento). Mientras estén
   sueltos, cada 30 s vuelven a enojar a su mesa.
7. **Se gana** cuando los 3 cabecillas están en la celda y quedan menos de 3 presos enojados. Sueldo de 600: 20 menos
   por cada mancha de los policías y 100 más si ningún guardia salió lastimado de la cocina. Cuota propia de 400, como
   el político.
8. **Se pierde** si el motín se desborda: con 15 presos enojados a la vez rompen la puerta de la cocina y se escapa el
   cocinero con la receta secreta del guiso (propuesta de chiste). Sin tiempo límite (decisión 66).
9. **El último cabecilla** que queda suelto, si los otros dos ya están en la celda, se escapa por la puerta de servicio
   en el carrito de la comida, cuesta abajo, y arranca la persecución (decisión 96). Agarrado, va a la celda; escapado,
   el caso se gana igual sin el extra.

## Las 10 variantes (de casos.md)
| # | Variante | Lo que cambia |
|---|---|---|
| 1 | Motín en el comedor | La base. **Primera variante a programar.** |
| 2 | Traslado de presos | 8 presos en un bus hasta la cárcel sin que se escape ninguno. |
| 3 | Día de visitas | Los visitantes pasan cosas escondidas; se revisa con las manos ([carcel-visitas.md](carcel-visitas.md)). |
| 4 | Túnel | Encontrar el túnel antes de que terminen de cavarlo; la pista es la tierra ([carcel-tunel.md](carcel-tunel.md)). |
| 5 | Concurso de talentos | El show distrae mientras otros se escapan y los policías son el jurado ([carcel-talentos.md](carcel-talentos.md)). |
| 6 | Lavandería | Se escapan dentro de los carritos de ropa ([carcel-lavanderia.md](carcel-lavanderia.md)). |
| 7 | Corte de luz | La cárcel a oscuras, solo con linternas ([carcel-corte-de-luz.md](carcel-corte-de-luz.md)). |
| 8 | Preso VIP | Un famoso que exige cosas absurdas y algunas traen escondida su fuga ([carcel-vip.md](carcel-vip.md)). |
| 9 | Huerta | Plantaron porotos mágicos entre las verduras y crecen hasta pasar el muro ([carcel-huerta.md](carcel-huerta.md)). |
| 10 | Recuento | Faltan presos y hay que contarlos con tiza mientras se mueven ([carcel-recuento.md](carcel-recuento.md)). |

## Lo que se reusa
- Objetos que vuelan en arco, manchan y se agarran en el aire: los huevos y tomates del político (`RallyThrowable`,
  `Grabber.catchable_near`).
- Esposas, escolta y patrullero del allanamiento y del banco; las rejas de la fuga (`CellDoor`) para la celda de
  castigo; la persecución embebida (`ChaseCase.begin`) con un vehículo nuevo, el carrito de la comida.
- Lo nuevo: la cárcel, el comedor, los presos con enojo que se contagia, la bandeja como escudo y volcar mesas.

## El orden para hacerlo (un PR chico por paso)
1. La cárcel en la ciudad (lote, muro, portón) y el comedor por dentro.
2. Los presos con enojo, el contagio y tirar comida.
3. Bandejas, volcar mesas, agarrar y devolver comida; los policías manchados que resbalan.
4. Calmar hablando; los cabecillas, esposarlos y la celda de castigo.
5. El final: sueldo, cuota, se desborda, el carrito y el sorteo de Jugar. Después, online.

## Preguntas para Cristian
1. **¿La cárcel va en la ciudad** (cuadra 5, 2, se llega en el patrullero), o es un lugar aparte que carga al salir de
   la comisaría? Recomendado: en la ciudad, como el banco, así la usan las 10 variantes.
2. **¿Calmar a los presos hablando** (acercarse y mantener E sin que te peguen), o solo esposar? Recomendado: hablar,
   así hay algo que hacer además de esposar a 20.
3. **¿Se pierde si se desborda** (15 enojados a la vez), o el motín no se pierde y solo baja el sueldo? Recomendado:
   se pierde, así el contagio importa.

## Respuestas de Cristian (23/10, decisión 104)
1. Sí: la cárcel va en la ciudad, en la cuadra 5, 2, y se llega en el patrullero.
2. Sí, y esposar también: a un preso se lo calma hablándole o esposándolo.
3. Sí: con 15 presos enojados a la vez el motín se desborda y el caso se pierde.

## Hecho así
- **Paso 1 (la cárcel y el comedor):** `PrisonLevel` (`scenes/levels/prison.tscn`, `--place=prison`) pone la cárcel en el lote "prison" de la cuadra (5, 2), mirando al oeste: un muro de 4,5 m con alambre arriba, el portón abierto con sus dos hojas de rejas y el cartel, el patio con un aro de básquet y la torre de vigilancia. Adentro del edificio, de dos pisos de alto, el comedor (6 mesas largas con bancos, `canteen_table`), el mostrador con ollas de puré y bandejas de gelatina (`prison_food_pot`, `prison_jelly_tray`), la puerta de la cocina cerrada con llave, la celda de castigo en la esquina oeste (`CellDoor` abierta) y, detrás de una reja con llave, el pabellón con 4 celdas de cada lado. Los policías salen de la comisaría y van en el patrullero. Capturas en `/mnt/project-files/carcel/paso1-*.png`.
- **Paso 2a (los presos y el enojo):** `PrisonRiot` pone 20 presos (`PrisonInmate`, modelo `npc_preso`) parados junto a las 6 mesas, en lugares que cambian con la semilla. Cada uno tiene un enojo de 0 a 100: arrancan algunos furiosos (5 desde el paso 2b) y el resto entre 10 y 45. Con 60 o más está enojado, le sale vapor rojo ("#@!") y grita ("¡Queremos postre!"). Nada se mueve hasta que el primer policía cruza el portón: ahí arranca el motín y el enojo de cada uno baja de a poco si nada lo molesta un rato. Captura en `/mnt/project-files/carcel/paso2-presos.png`.
- **Paso 2b (la comida y el contagio):** el preso enojado tira cada 6 s más o menos (`PrisonInmate.throw_at`) puré, gelatina, pollo o yogur, con la misma física que los huevos y tomates del político (`RallyThrowable`, modelos `prison_mash`, `prison_jelly`, `prison_chicken`, `prison_yogurt` y sus manchas). Le apunta al policía más cercano a menos de 12 m el 40% de las veces y si no a otro preso a menos de 8 m (`PrisonRiot.target_for`), con más error al policía (0,8 m) que a un preso (0,5 m). La comida que le pega a un preso lo mancha y le sube 35 de enojo; el enojo baja 1,5 por segundo después de 6 s tranquilo. A un policía le suma una mancha (`food_hits`, para resbalar en el paso 3). Medido sin policías en el comedor: unos 15 enojados a los 100 s, así que solo el motín llega a desbordarse en un par de minutos. Arrancan 5 enojados. Captura en `/mnt/project-files/carcel/paso2-comida.png`.
- **Paso 3 (bandejas, mesas y resbalones):** E sobre una mesa (`CanteenTable`) la vuelca hacia el policía: la tabla queda parada como una pared entre él y los presos del otro lado, y los presos de ese lado saltan 1 m para atrás con 20 más de enojo. E otra vez la levanta. Junto al mostrador hay una pila de 8 bandejas (`PrisonTray`, modelo `prison_tray`): agarrada, la bandeja se pone de frente a donde mira el policía, para la comida y le queda la mancha a ella (`tray_blocks`). Un policía con 5 manchas de comida encima resbala: suelta lo que tiene, queda 2 s en el piso y se le van las manchas (`food_slips`). Capturas en `/mnt/project-files/carcel/paso3-*.png`.
- **Paso 4 (calmar, esposar y los cabecillas):** con E mantenida sobre un preso, cerca (2,5 m) y mirándolo, el policía le habla y le baja 12 de enojo por segundo; la charla se corta si suelta E, se aleja, deja de mirarlo o le pega comida. En 0 el preso se sienta en el banco. Esposado, el preso queda en 0 y no tira nada mientras duran las esposas. Los 3 cabecillas (uno por mesa, distintas mesas por semilla) arrancan en 100, el enojo nunca les baja, están parados arriba de su mesa con sus propios gritos y no escuchan. Cada 30 s los que siguen sueltos se vuelven a subir y le suman 40 de enojo a su mesa. Volcar la mesa los baja. Esposados, E los lleva del brazo a la celda de castigo (`PrisonEscort`, la escolta del allanamiento) y ahí quedan; los encerrados no cuentan como enojados. Capturas en `/mnt/project-files/carcel/paso4-*.png`.
- **Paso 5a (el caso):** el comisario lo cuenta en su oficina y Q abre la planilla (`PrisonCase`). Se gana con los 3 cabecillas en la celda y menos de 3 presos enojados: sueldo de 600, 20 menos por cada comida que le pegó a un policía y 100 más si ningún cabecilla se escapó (el extra de los guardias de la cocina queda para cuando haya guardias: no hay todavía). Cuota propia de 400. Con 15 enojados a la vez se desborda: rompen la puerta de la cocina, el cocinero se escapa con la receta del guiso y el caso se pierde. Premios nuevos: Blanco móvil (comidas encima), Mozo del año (tapadas con la bandeja) y Patinador sobre puré (caídas). En el sorteo de Jugar, uno de cada 4 de lo que queda (`PlaceDraw.PRISON_EVERY`). Capturas en `/mnt/project-files/carcel/paso5-*.png`.
- **Paso 5b (el carrito de la comida):** con los otros dos cabecillas en la celda, el que queda suelto tiene 3 s; si no lo esposan, se escapa cuesta abajo en el carrito de la comida (`SuspectCar.FOOD_CART`, modelo `food_cart`, 14 km/h por la vereda) y arranca la persecución embebida (`ChaseCase.begin`). Sale por el portón y no por una puerta de servicio (no hay puerta de servicio en el muro; propuesta). Mientras dura, el comedor se queda quieto mirando. Atrapado cuenta como encerrado y paga el extra de 100; escapado, el caso se gana igual sin el extra. Captura en `/mnt/project-files/carcel/paso5-carrito.png`.
- **Paso 6 (online):** decide el anfitrión. Los presos van por `NpcSync` (dónde están, qué gritan, el enojo, las esposas y si están en la celda); la planilla, los cabecillas encerrados, el desborde, el carrito y el fin de turno, por `CaseSync` (`PrisonCase.snapshot`). Las mesas se vuelcan en todas las PC (`ActionSync`) y hablarle a un preso también. Cada comida que revienta en el anfitrión se avisa a los invitados (`show_burst`): la mancha en el policía (y el resbalón, en la PC de ese jugador), en el preso o en el piso. Falta: las manchas de las bandejas no se ven en los invitados.
