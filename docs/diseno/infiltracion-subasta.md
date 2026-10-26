# Infiltración: Subasta de arte (variante 9 de infiltracion.md)

Undécima variante de la infiltración, después del Club de abuelos, el Coro de iglesia, la Banda de mimos, la Fiesta
de disfraces, el Gimnasio, la Escuela de ladrones, el Restaurante, el Club de ajedrez y la Banda de motociclistas
(decisión 177, propuesta del 26/10). Se reusa casi todo: el lugar como `InfiltrationPlace`, la gente que mira con su
medidor (`ClubMember` y `ClubSuspicion`), el disfraz con las manos, 3 pruebas de 6 por la semilla, el caso con la
planilla y el sueldo (`InfiltrationCase.VARIANTS`), la huida con persecución si los descubren y el sorteo de "Jugar".
Lo nuevo es **la subasta**: los policías tienen que pujar como compradores de verdad, con plata de la cuota, y si se
quedan con algo, lo pagan. Todo lo que dice **(propuesta)** se ajusta jugando.

## La historia
La casa de subastas "El Martillo de Oro" vende cuadros robados de los museos de la ciudad, cambiados por copias tan
malas que nadie se da cuenta (o eso creen). El jefe es Don Martillo, el subastador, que golpea el martillo con
demasiadas ganas. Los policías entran como millonarios, se sientan entre los compradores, pujan para no llamar la
atención, juntan 3 pruebas y esposan a Don Martillo.

El chiste: cuatro policías con el sueldo de un novato haciéndose pasar por millonarios, que tienen que levantar la
paleta para disimular y rezar para que alguien puje más alto. Y si se quedan con el jarrón feo, lo pagan.

## Cómo es
1. **El lugar:** "El Martillo de Oro", un lote nuevo de la ciudad **(propuesta)**: la sala de la subasta con el
   podio de Don Martillo, el atril de los lotes y filas de sillas con paletas numeradas; la galería con los cuadros
   que se van a subastar; el depósito de atrás con cajas y el taller del falsificador; y la oficina de Don Martillo
   (con llave). Entre 8 y 10 compradores (algunos son de la banda) y el portero de la puerta **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay, por policía, un monóculo (a la cara), una galera (a la
   cabeza) y un moño con frac (al pecho). Con 2 de las 3 el policía pasa por millonario (`is_disguised("auction")`).
   Con el uniforme, el portero no lo deja pasar: "Solo compradores. Y los compradores no traen esposas."
   **(propuesta)**.
3. **La subasta (lo nuevo):** a los 20 s y después cada 60 s Don Martillo saca un lote (un cuadro horrible, un jarrón,
   una estatua, una silla "de época") y empieza en 100 **(propuesta)**:
   - **pujar:** sentado en una silla de la sala, E levanta la paleta y sube 50 el precio. Los compradores de la sala
     también pujan, cada uno hasta un tope que la semilla elige (entre 150 y 600);
   - **el martillo:** si nadie puja en 6 s, Don Martillo cuenta "A la una... a las dos..." y baja el martillo: el
     lote es del último que pujó;
   - **hay que pujar:** si en un lote ningún policía levantó la paleta ni una vez, los compradores sospechan (+25 a
     los de la sala: "¿Vinieron a mirar? Esto no es un museo.");
   - **y si compran, pagan:** si el último en pujar fue un policía, el lote es suyo. Le llega a la silla (un objeto
     con física, para llevarse o tirar) y el precio se resta del sueldo del turno, en una línea nueva de la planilla
     ("Compras en la subasta"). El truco es pujar temprano, cuando los demás todavía van a subir, y bajar la paleta a
     tiempo;
   - mientras dura un lote, los compradores miran el podio: es el mejor momento para que los otros revisen la galería
     y el depósito.
4. **La sospecha:** la del club con otros textos: sin disfraz, con una herramienta de policía en la mano, en la
   oficina, una pieza del disfraz que se cae y los lotes en los que nadie pujó. A 100 un comprador grita "¡Son
   policías! ¡Ningún millonario pregunta si aceptan cupones!".
5. **Las 3 pruebas** (la semilla elige 3 de 6) **(propuesta)**:
   - el cuadro original robado, escondido detrás de su copia en el depósito (se agarra, grande);
   - foto del catálogo con los precios "de verdad" en código, sobre el atril;
   - el taller del falsificador, con la copia a medio pintar y los pomos de pintura (foto);
   - el video de dos compradores hablando de "el original del martes" (5 s cerca con la cámara, como el club);
   - uno de los lotes de la subasta es una pieza robada de verdad: si un policía se lo queda, es prueba (pero lo
     paga); si lo compra otro, se pierde;
   - el libro de ventas en el escritorio de la oficina (E; la llave está debajo del martillo, en el podio: E en el
     podio cuando Don Martillo no mira).
6. **Se gana** esposando a Don Martillo: sueldo de 600, un tercio menos por cada prueba que falte, menos lo que hayan
   comprado, cuota de 400, igual que las otras infiltraciones. Esposar a un comprador los descubre. Detenido, el turno
   siguiente puede ser su interrogatorio (decisión 93): se le escapan 3 frases y confiesa.
7. **Si los descubren:** Don Martillo se escapa por la calle en el carrito eléctrico de la galería, con un cuadro
   gigante atado atrás que se le va de costado en cada curva, a 20 km/h **(propuesta)**.
8. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en el ajedrez y la banda de motos: la semilla (los compradores, sus topes, los lotes y
el lote robado), quién pujó, el precio, cuándo baja el martillo y quién se queda con el lote, la sospecha de cada
comprador, lo que se resta del sueldo y las pruebas. Lo que dice Don Martillo y el precio del lote llegan a todos, y el
lote comprado es un objeto con física que se sincroniza como los demás (`PropSync`).

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "auction"), `ClubMember` (compradores y Don Martillo),
`ClubSuspicion` (con `prefix` "AUCTION_"), `ClubDoorman` (el portero), `ClubEvidence` y `ClubEvidenceSpot`, `KeyPot`,
`DisguisePiece` (tres piezas nuevas), `PlaceBuilder`, `ChaseCase` con un `SuspectCar` nuevo, `PlaceDraw` y `NpcSync`.
La subasta copia la forma de `ChessGames` y `BikerDares` (el host decide y avisa).

## El orden para hacerlo (un PR chico por paso)
1. El disfraz: monóculo, galera y moño con frac en el casillero, 2 de 3.
   Hecho así: 12 piezas en una fila detrás de la de los motoqueros, al lado del café: monóculo dorado con cadenita
   sobre el ojo derecho (cara), galera negra alta con cinta roja (cabeza, tapa la gorra) y frac negro con pechera
   blanca, moño rojo y dos colas atrás (pecho; doblado en el piso). Con 2 de las 3, `is_disguised("auction")`
   **(propuesta)**.
2. La casa de subastas en la ciudad (`--place=auction`): la sala, la galería, el depósito, la oficina, los
   compradores, Don Martillo y el portero.
   Hecho así: un lote nuevo en la cuadra (6, 2), al sur, de 24 x 20 m, color crema con el cartel dorado. El portero
   (levita bordó con botones dorados, guantes blancos y galera baja) está en la entrada. Adelante, la sala con
   alfombra roja, el podio de Don Martillo al fondo, el atril de los lotes y 15 sillas doradas en 3 filas mirando al
   podio; al este, la galería con 5 cuadros de colores en marcos dorados y un jarrón en un pedestal. Atrás, el
   depósito (con cuadros embalados) y la oficina con llave detrás de la galería. La semilla reparte 8 compradores (dos
   modelos: saco de terciopelo bordó con monóculo y paleta, y vestido verde con perlas y sombrero con pluma) entre 11
   lugares: 7 sillas (sentados), la galería y el depósito. Don Martillo (frac blanco, moño rojo, bigote enrulado y
   martillo dorado) está detrás del podio mirando a las sillas **(propuesta)**.
3. Lo de la sala: el podio con el martillo, el atril de los lotes, las sillas con paletas y el cartel del precio.
   Hecho así: 15 sillas doradas con tapizado rojo, numeradas, mirando al podio; E en una silla levanta su paleta
   blanca con el número (se ve 1,5 s sobre la silla). El podio de madera oscura con placa dorada tiene el martillo
   dorado, que se levanta y baja con un "toc", y arriba el cartel con el precio ("$ 350"), vacío entre lotes. Al lado,
   el atril de madera donde se pone el lote: un retrato horrible de un señor verde, un jarrón azul, un busto de mármol
   o una sillita "de época" rosa **(propuesta)**.
4. La subasta: los lotes, las pujas de los policías y de los compradores, el martillo, la sospecha y lo que se paga.
5. Las pruebas y el caso (variante "auction"): las 6 pruebas, el sueldo con las compras y el interrogatorio.
6. La huida en el carrito de la galería, el sorteo de "Jugar" en décimos y online.

## Preguntas para Cristian (decisión 177)
1. **¿Hay subasta de verdad cada 60 s, donde hay que pujar al menos una vez por lote (si no, sospechan) y, si un
   policía se queda con el lote, el precio se resta del sueldo del turno?** Recomiendo que sí: es lo que dice el caso
   ("se puja con plata de la cuota, y si compran algo, lo pagan"), y obliga a elegir cuándo dejar de pujar.
2. **¿Los policías se disfrazan de millonario (monóculo, galera y moño con frac, 2 de 3)?** Recomiendo que sí, para
   mantener la regla del disfraz.
3. **¿Don Martillo escapa en el carrito eléctrico de la galería con un cuadro gigante atado que se le va de costado en
   las curvas, a 20 km/h?** Recomiendo que sí: es lento y el cuadro tapa la vista del patrullero.

Mientras no respondas, se avanza con lo recomendado.
