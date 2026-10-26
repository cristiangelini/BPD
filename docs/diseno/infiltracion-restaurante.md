# Infiltración: Restaurante (variante 3 de infiltracion.md)

Octava variante de la infiltración, después del Club de abuelos, el Coro de iglesia, la Banda de mimos, la Fiesta de
disfraces, el Gimnasio y la Escuela de ladrones (decisión 174, propuesta del 26/10). Se reusa casi todo: el lugar como
`InfiltrationPlace`, la gente que mira con su medidor (`ClubMember` y `ClubSuspicion`), el disfraz con las manos, 3
pruebas de 6 por la semilla, el caso con la planilla y el sueldo (`InfiltrationCase.VARIANTS`), la huida con
persecución si los descubren y el sorteo de "Jugar". Lo nuevo es **cocinar de verdad**: cada tanto entra una comanda
y los policías tienen que armar el plato con las manos (agarrar los ingredientes, ponerlos en la olla o la sartén,
esperar que se cocinen sin que se quemen, servirlos en un plato y llevarlo al pase). Todo lo que dice **(propuesta)**
se ajusta jugando.

## La historia
El restaurante "La Cuchara de Oro" es la fachada de una banda que vende joyas robadas: el Chef Flambé, el jefe, las
esconde en el "plato especial" que sale para la mesa del comprador. Los policías entran como cocineros nuevos, tienen
que cocinar para que no los echen (ni sospechen), juntan 3 pruebas y esposan al Chef.

El chiste: cuatro policías que no saben ni hervir agua, con el Chef gritando "¡Servicio!" y una sopa que sale con un
anillo de diamantes adentro.

## Cómo es
1. **El lugar:** "La Cuchara de Oro", un lote nuevo de la ciudad **(propuesta)**: el salón con mesas (los clientes son
   decorado), el pase (el mostrador entre el salón y la cocina, con una campanita), la cocina con 4 hornallas, la mesada
   para cortar y emplatar, la despensa con cajones de verduras, la cámara fría y la oficina del Chef (con llave).
   Entre 6 y 8 cocineros y mozos de la banda **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay, por policía, un gorro de cocinero alto (a la cabeza), un bigote
   enrulado (a la cara) y un delantal blanco (al pecho). Con 2 de las 3 el policía pasa por cocinero
   (`is_disguised("chef")`). Con el uniforme, el maître no lo deja pasar a la cocina: "¿Policía? La cocina es solo para
   el personal. Y está todo en regla. Todo." **(propuesta)**.
3. **Las comandas (lo nuevo):** a los 20 s y después cada 40 s el Chef grita una comanda y la cuelga en el riel **(propuesta)**.
   Hay 60 s para dejar el plato en el pase y tocar la campanita. Recetas **(propuesta)**:
   - **sopa:** tomate y cebolla en la olla, 6 s al fuego;
   - **ensalada:** lechuga y tomate en un plato, sin fuego;
   - **pescado frito:** pescado en la sartén, entre 4 y 8 s al fuego (después de 8 s se quema y sale humo);
   - **fideos:** fideos en la olla, 5 s al fuego, y un tomate arriba ya en el plato.
   Los ingredientes son objetos físicos que se agarran (despensa y cámara fría) y se tiran en la olla, la sartén o el
   plato; la olla y la sartén se agarran y se vuelcan en el plato. Plato bien y a tiempo: el Chef dice "¡Eso!". Plato
   mal (le falta o le sobra algo, crudo o quemado), o que no sale a tiempo: cada cocinero que ve la cocina suma +20, y
   +30 si se quemó (el humo se ve desde el salón) **(propuesta)**. Un plato quemado que se deja en el fuego prende un
   fueguito que se apaga con el matafuegos de la pared.
4. **El plato especial:** una de cada tres comandas es "¡Una sopa especial para la mesa 7!". Esa la arma el Chef
   mismo, que mete un anillo robado en la olla: si un policía saca una foto del anillo en la sopa antes de que llegue a
   la mesa, es una prueba **(propuesta)**.
5. **La sospecha:** la del club con otros textos: sin disfraz, con una herramienta de policía en la mano, en la oficina,
   una pieza del disfraz que se cae y los platos mal. A 100 un cocinero grita "¡Son policías! ¡Nadie cocina tan mal!".
6. **Las 3 pruebas** (la semilla elige 3 de 6) **(propuesta)**:
   - la libreta de cuentas debajo de la caja registradora (se agarra);
   - foto del anillo en la sopa especial (cuando sale una);
   - la olla con doble fondo, con collares adentro, en la cámara fría (se agarra);
   - el video de dos cocineros hablando del comprador de la mesa 7 (5 s cerca con la cámara, como el club);
   - foto de la pizarra del menú con precios en código ("Sopa: 3 quilates");
   - el recibo de la joyería en el cajón de la oficina del Chef (E; la llave de la oficina está en el bolsillo del
     delantal colgado en la cámara fría).
7. **Se gana** esposando al Chef Flambé: sueldo de 600, un tercio menos por cada prueba que falte, cuota de 400, igual
   que las otras infiltraciones. Esposar a un cocinero o a un mozo los descubre. Detenido, el turno siguiente puede ser
   su interrogatorio (decisión 93): se le escapan 3 frases y confiesa.
8. **Si los descubren:** el Chef sale por la puerta de la cocina y escapa en la moto de delivery del restaurante, con
   la caja térmica gigante atrás, a 40 km/h por la calle; en cada curva se le cae una pizza **(propuesta)**.
9. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en el gimnasio y la escuela: la semilla (los cocineros, las pruebas y el orden de las
comandas), cuándo entra cada comanda, qué hay en cada olla y plato, si el plato salió bien, la sospecha de cada
cocinero y las pruebas. Los ingredientes, las ollas y los platos son objetos con física que ya se sincronizan como los
demás (`NpcSync` / el agarre), y el fuego de cada hornalla lo cuenta el host.

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "restaurant"), `ClubMember` (cocineros, mozos y el Chef),
`ClubSuspicion` (con `prefix` "RESTAURANT_"), `ClubDoorman` (el maître), `ClubEvidence` y `ClubEvidenceSpot`,
`KeyPot`, `DisguisePiece` (tres piezas nuevas), `PlaceBuilder`, `ChaseCase` con un `SuspectCar` nuevo, `PlaceDraw` y
`NpcSync`. Las comandas copian la forma de `GymRoutine` y `SchoolClasses` (el host decide y avisa).

## El orden para hacerlo (un PR chico por paso)
1. El disfraz de cocinero: gorro, bigote enrulado y delantal en una fila frente a los casilleros, y el look "chef" (2
   de 3).
   Hecho así: 12 piezas en una octava fila a 4,85 m frente a los casilleros (gorro alto blanco, bigote enrulado
   marrón y delantal sobre una chaqueta blanca con botones). Con 2 de 3, `is_disguised("chef")`. Correr la hace caer
   como cualquier disfraz **(propuesta)**.
2. El restaurante en la ciudad (`--place=restaurant`): el salón, el pase, la cocina, la despensa, la cámara fría y la
   oficina; los cocineros, los mozos, el Chef y el maître.
   Hecho así: un lote nuevo en la cuadra (1, 0), al sur, de 24 x 20 m. Desde la entrada, el salón (8 mesas con
   mantel, la 7 con su número, la caja registradora y la pizarra del menú con precios en quilates), abierto a
   cualquiera. Después, la pared con el pase (una ventana sobre un mostrador con la campanita) y la puerta de la
   cocina, donde el maître solo deja pasar con 2 piezas de cocinero. En la cocina, las 4 hornallas en la pared del
   fondo, la mesada en el medio y la pileta; atrás, la despensa (oeste), la cámara fría (medio) y la oficina del Chef
   con llave (este). 4 cocineros (chaqueta blanca y pañuelo rojo, o con redecilla y delantal manchado) en 4 de 6
   lugares de la cocina por la semilla (los 2 que sobran son para los policías) y 3 mozos (chaleco negro y moño) en el
   salón mirando al pase. El Chef Flambé (gorro altísimo, bigote enrulado y sartén con llamita) en el pase, mirando la
   cocina. La sospecha solo cuenta en la cocina y atrás: el salón es público **(propuesta)**.
3. La cocina: los ingredientes, la olla, la sartén, las hornallas (cocido, quemado y humo) y los platos.
   Hecho así: en la despensa, 4 cajones en el piso (tomate, cebolla, lechuga y fideos) y en la cámara fría el de
   pescado; E en un cajón pone un ingrediente encima, hasta 6 sueltos de cada uno ("ya hay de sobra"). 2 ollas en
   las primeras hornallas, 2 sartenes y 6 platos en la mesada. Un ingrediente que se suelta (no en la mano) dentro
   de una olla, una sartén o un plato entra. Una olla o una sartén parada sobre una hornalla cocina lo que tiene;
   pasados 12 s la olla y 8 s la sartén se quema: se pone negro y echa humo. E con una olla o una sartén en la mano la
   vuelca en el plato más cercano (a 1 m), y el plato recuerda en qué se cocinó cada cosa y cuánto, para las comandas
   del paso 4. El host decide todo y les cuenta a los demás. El fuego que se prende y el matafuegos quedan para
   después **(propuesta)**.
4. Las comandas: el riel, las recetas, el pase con la campanita, el plato bien o mal y la sospecha.
5. Las pruebas y el caso (variante "restaurant"): el plato especial, las 6 pruebas, el sueldo y el interrogatorio.
6. La huida en la moto de delivery, el sorteo de "Jugar" en séptimos y online.

## Preguntas para Cristian (decisión 174)
1. **¿Hay que cocinar de verdad, con comandas cada 40 s y recetas que se arman con las manos (ingredientes, olla,
   fuego, plato y al pase)?** Recomiendo que sí: es lo que dice el caso ("hay que cocinar de verdad") y con física y
   cuatro amigos sale el caos que buscamos.
2. **¿Los policías se disfrazan de cocinero (gorro, bigote enrulado y delantal, 2 de 3)?** Recomiendo que sí, para
   mantener la regla del disfraz.
3. **¿El Chef escapa en la moto de delivery perdiendo pizzas en las curvas?** Recomiendo que sí: es rápida pero se
   puede seguir por el rastro de pizzas.

Mientras no respondas, se avanza con lo recomendado.
