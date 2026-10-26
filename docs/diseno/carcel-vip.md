# Cárcel 6.8: Preso VIP

Decisión 145 (propuesta). Caso de la cárcel ([carcel-motin.md](carcel-motin.md), fila 8 de la tabla). Todos los
números son (propuesta).

## La idea
Rulo Brillantina, el cantante más famoso de la ciudad, pasa un día preso por estacionar su limusina en la puerta de
los bomberos. La cárcel le dio la mejor celda del pabellón y los policías tienen que atenderlo. Rulo pide cosas
absurdas sin parar, y algunas de las cosas que pide traen escondido algo para escaparse: sus fans lo esperan en el
portón. El chiste: **hay que tenerlo contento y, a la vez, revisar todo lo que se le lleva**.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, hoy cuidan a Rulo Brillantina. Sí, ese. Denle lo que pida,
   que si se enoja sale en la tele. Pero revisen todo: sus fans son capaces de cualquier cosa".
2. **La celda VIP:** la celda del pabellón que elige la semilla tiene alfombra roja, un sillón dorado y luces de
   camarín. Rulo (anteojos de sol, campera brillante, el modelo del preso con otro color) está adentro con la puerta
   cerrada. Afuera, en la vereda del portón, 6 fans con carteles gritan "¡RULO, RULO!" y su limusina rosa espera.
3. **Los pedidos:** cada 45 s Rulo toca su campanita y pide algo (se ve en un globito y en la planilla, con 60 s para
   cumplirlo). La semilla elige 6 de 10 pedidos: agua con gas (la heladera de la cocina), una almohada de plumas (la
   lavandería), una torta de cumpleaños (la cocina), un espejo (el baño de los guardias), una guitarra (la sala de
   los guardias), un ramo de flores (las macetas del patio), sus anteojos de repuesto (la limusina, por la reja), un
   masaje de pies (un policía 5 s al lado de la reja con E apretada), un aplauso (2 policías con E al mismo tiempo
   frente a la celda) y una canción (un policía canta, la tecla de tararear, 5 s).
4. **Las cosas escondidas:** 3 de las cosas que se traen (la semilla elige cuáles) esconden una pieza de la fuga: una
   lima en la torta, una soga en la guitarra o una llave en el ramo. Se revisan como en el día de visitas: con la
   cosa en la mano, R la abre y la pieza cae al piso (se lleva a la caja de decomisos del portón). Revisada, la cosa
   igual se le puede dar.
5. **El humor de Rulo:** empieza en 60 de 100. Un pedido cumplido a tiempo suma 20; uno vencido resta 25 y hace un
   berrinche (grita, tira la almohada, "¡¿Saben quién soy yo?!"). Con el humor en 0 llama a su abogado, que llega,
   le habla 30 s y se va; el sueldo baja 100 por cada abogado.
6. **La fuga:** cada pieza que Rulo recibe se guarda. Apenas junta las 3 (lima, soga y llave) se escapa por la
   reja, corre por el pasillo y el patio hacia su limusina en el portón. Se lo esposa y se lo lleva de vuelta a su
   celda; si llega a la limusina, se pierde el caso.
7. **El final:** el día de Rulo dura 6 pedidos. Cuando se cumple (o se vence) el último, viene su manager con los
   papeles y se lo lleva por la puerta. **Se gana** si Rulo se va así; **se pierde** si se escapa en la limusina.
8. **El sueldo:** 600, 25 más por cada pedido cumplido a tiempo, 50 más por cada pieza decomisada, 100 menos por cada
   abogado. Cuota propia de 400, como las otras cárceles.

## Lo que cambia con la semilla
En qué celda está Rulo, qué 6 pedidos hace y en qué orden, qué 3 cosas esconden una pieza y qué pieza.

## Lo que se reusa
- La cárcel, el pabellón y sus celdas con puerta (`PrisonLevel`, `CellDoor`), la cocina, la lavandería y el patio.
- Abrir con R lo que se tiene en la mano y la caja de decomisos (`VisitItem`, del día de visitas).
- El que corre al portón, las esposas y llevarlo del brazo (`BlackoutInmate`, `BlackoutEscort`), con su celda en
  vez de la de castigo.
- Tararear (`hum`) para la canción, y el globito de texto.
- Lo nuevo: Rulo y su celda VIP, la campanita y los pedidos, el humor, los fans y la limusina, el abogado y el
  manager.

## Atajos del panel de pruebas (cuando exista)
- Abrir el preso VIP (`--place=prison_vip`).
- Pedir el próximo pedido ya.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. La celda VIP con Rulo, los fans y la limusina en el portón (`--place=prison_vip`).
3. Los pedidos: la campanita, el globito, los 10 pedidos con sus cosas en la cárcel, el tiempo y el humor.
4. Lo que esconden: las 3 piezas, revisar con R, la caja de decomisos y el abogado.
5. La fuga: con las 3 piezas sale corriendo a la limusina, esposarlo y llevarlo a su celda; el manager al final.
6. El caso: el comisario, la planilla, el sueldo, la cuota y el sorteo en Jugar (`PlaceDraw.PRISONS`, en octavos).
7. Online: Rulo, los pedidos, las cosas, los fans y el final.

## Preguntas para Cristian
1. **¿Los pedidos se cumplen trayendo cosas que están por la cárcel** (y algunas esconden una pieza para la fuga)?
   Recomendado: sí, así hay que salir a buscar y repartirse.
2. **¿Con el humor en 0 no se pierde, solo cuesta 100 del sueldo** (el abogado)? Recomendado: sí, así lo que se
   pierde de verdad es que se escape, y lo otro es un castigo chico.
3. **¿Se escapa cuando junta las 3 piezas y se pierde si llega a la limusina?** Recomendado: sí, así revisar las
   cosas importa más que darle todo rápido.

## Hecho así
- **Paso 2:** `--place=prison_vip` (`scenes/levels/prison_vip.tscn`, `PrisonLevel.variant = "vip"`). El pabellón
  abierto y las 8 celdas con puerta; la que sortea la semilla (`VipPlan`) tiene la alfombra roja, el sillón dorado
  mirando a la reja, el espejo de camarín con focos y una luz cálida, y la puerta con llave. Rulo (`VipInmate`, modelo
  `npc_rulo`) está sentado en el sillón y dice cosas cada 12 s. En la vereda, a los dos lados del portón, los 6 fans
  (`VipFan`, modelo `npc_fan`) saltan y gritan "¡RULO, RULO!" por turnos, y la limusina rosa (`limo`) espera junto al
  cordón. Capturas en la carpeta del proyecto `carcel-vip/`: `paso2-celda.png` y `paso2-porton.png`.
- **Paso 3:** `VipRequests`: la campanita suena cuando el primer policía entra por el portón y después cada 45 s, con
  el pedido en el globito de Rulo y en un cartel sobre su reja (su humor y cada pedido abierto con los segundos que le
  quedan). Las cosas están en: la heladera nueva de la cocina (agua con gas, `VipGift`), la cucheta de la celda de
  castigo (almohada), la punta del mostrador (torta, `VisitItem`), al lado de la torre (espejo, en vez del baño de los
  guardias, que no existe), una mesa del comedor (guitarra), un cantero nuevo del patio (flores) y el techo de la
  limusina (anteojos). Se entregan dejándolas en la repisa dorada de su reja (`VipTray`), o con E teniéndolas en la
  mano; él las agarra y quedan en fila al lado de su sillón. Lo que no pidió no lo agarra. El masaje son 5 toques de E
  en la repisa (en vez de 5 s con E apretada, para que sea igual online); el aplauso, 2 policías con E en 2 s (uno
  solo si juega uno solo); la canción, cantar o tararear (H) a menos de 4 m de la repisa durante 5 s. Vencido: -25 y
  berrinche (salta en el sillón gritando). Capturas: `paso3-pedido.png`, `paso3-entregado.png` y `paso3-torta.png`.
