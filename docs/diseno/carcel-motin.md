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
| 3 | Día de visitas | Los visitantes pasan cosas escondidas; se revisa con las manos. |
| 4 | Túnel | Encontrar el túnel antes de que terminen de cavarlo. |
| 5 | Concurso de talentos | El show distrae a los guardias mientras otros se escapan. |
| 6 | Lavandería | Se escapan dentro de los carritos de ropa. |
| 7 | Corte de luz | La cárcel a oscuras, solo con linternas. |
| 8 | Preso VIP | Un famoso que exige cosas absurdas (como los pedidos de El Oso). |
| 9 | Huerta | Plantaron algo raro y hay que encontrarlo. |
| 10 | Recuento | Faltan presos y hay que contarlos mientras se mueven. |

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
