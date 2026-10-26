# Infiltración: Club de ajedrez (variante 1 de infiltracion.md)

Novena variante de la infiltración, después del Club de abuelos, el Coro de iglesia, la Banda de mimos, la Fiesta de
disfraces, el Gimnasio, la Escuela de ladrones y el Restaurante (decisión 175, propuesta del 26/10). Se reusa casi
todo: el lugar como `InfiltrationPlace`, la gente que mira con su medidor (`ClubMember` y `ClubSuspicion`), el disfraz
con las manos, 3 pruebas de 6 por la semilla, el caso con la planilla y el sueldo (`InfiltrationCase.VARIANTS`), la
huida con persecución si los descubren y el sorteo de "Jugar". Lo nuevo es **jugar mientras se espía**: los socios
desafían a los policías a partidas con reloj, y el que juega tiene que mover piezas con las manos y tocar el reloj a
tiempo mientras los otros buscan pruebas. Todo lo que dice **(propuesta)** se ajusta jugando.

## La historia
El club de ajedrez "El Peón Dormido" es la cueva de una banda que pasa diamantes robados escondidos adentro de piezas
de ajedrez huecas. El jefe es el Gran Maestro Alfil, que nunca perdió una partida (porque nadie se anima a ganarle).
Los policías entran como socios nuevos, juegan para que no sospechen, juntan 3 pruebas y esposan al Gran Maestro.

El chiste: cuatro policías que no saben cómo se mueve el caballo, jugando partidas rápidas contra señores muy serios
que dicen "interesante..." cada vez que alguien mueve la torre en diagonal.

## Cómo es
1. **El lugar:** "El Peón Dormido", un lote nuevo de la ciudad **(propuesta)**: el salón con 8 mesas de ajedrez con
   reloj, la sala del torneo (la mesa del Gran Maestro sobre una tarima, con público), la cafetería, la vitrina de
   trofeos, el depósito de tableros y la oficina del Gran Maestro (con llave). Entre 8 y 10 socios de la banda y el
   portero **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay, por policía, unos anteojos gruesos (a la cara), un chaleco de
   rombos (al pecho) y una boina de pensador (a la cabeza). Con 2 de las 3 el policía pasa por socio
   (`is_disguised("chess")`). Con el uniforme, el portero no lo deja pasar: "Socios solamente. Y los socios no usan
   placa." **(propuesta)**.
3. **Las partidas (lo nuevo):** cada 45 s un socio se sienta en una mesa libre y desafía a un policía por su nombre:
   "¡Tú, el nuevo! ¿Una partida?" **(propuesta)**. Ese policía tiene 15 s para sentarse frente a él (si no, +20 de
   sospecha de los que miran). La partida dura 60 s con turnos:
   - el socio mueve una pieza y toca el reloj;
   - el policía tiene 8 s para mover una pieza suya (agarrarla y soltarla en otra casilla del tablero, con las manos)
     y tocar el reloj (E). No se revisa si el movimiento es legal: los socios lo comentan ("Interesante...", "Muy poco
     ortodoxo", "¿El caballo vuela ahora?");
   - si se le acaba el tiempo, el socio grita "¡Tiempo!" y suma +20; si el policía se levanta en medio de la partida,
     +30; si tira el tablero (las piezas son objetos con física), +40 y todos miran.
   Al final de la partida el socio se va contento y, a veces, le cuenta un chisme que ayuda a encontrar una prueba
   **(propuesta)**. Mientras uno juega, los demás pueden buscar: el chiste es turnarse y cubrirse.
4. **El torneo del Gran Maestro:** el Gran Maestro juega en la tarima contra un socio, con público alrededor. Mientras
   la partida del torneo sigue, el público mira la tarima y no la sala: es el mejor momento para revisar cosas
   **(propuesta)**.
5. **La sospecha:** la del club con otros textos: sin disfraz, con una herramienta de policía en la mano, en la
   oficina, una pieza del disfraz que se cae y las partidas mal jugadas. A 100 un socio grita "¡Son policías! ¡Nadie
   juega tan mal al ajedrez!".
6. **Las 3 pruebas** (la semilla elige 3 de 6) **(propuesta)**:
   - el rey negro hueco con diamantes, en el tablero del Gran Maestro (se agarra, mientras no está mirando);
   - foto de la planilla de partidas en código ("1. e4 = 4 diamantes") colgada en la cafetería;
   - el maletín con piezas huecas al lado de la tarima (se agarra, pesado);
   - el video de dos socios hablando de "la entrega del sábado" (5 s cerca con la cámara, como el club);
   - la copa de la vitrina llena de relojes robados (E);
   - el libro de cuentas en el cajón de la oficina del Gran Maestro (E; la llave está pegada debajo de la mesa 8).
7. **Se gana** esposando al Gran Maestro Alfil: sueldo de 600, un tercio menos por cada prueba que falte, cuota de
   400, igual que las otras infiltraciones. Esposar a un socio los descubre. Detenido, el turno siguiente puede ser su
   interrogatorio (decisión 93): se le escapan 3 frases y confiesa.
8. **Si los descubren:** el Gran Maestro sale a la calle en un caballito de calesita a motor (con cabeza de caballo de
   ajedrez), a 25 km/h, que en cada esquina da un salto en L **(propuesta)**.
9. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en el restaurante y la escuela: la semilla (los socios, las pruebas y el orden de los
desafíos), a quién desafían, cuándo termina cada turno y si se tocó el reloj a tiempo, la sospecha de cada socio y las
pruebas. Las piezas son objetos con física que ya se sincronizan como los demás (`NpcSync` / el agarre).

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "chess"), `ClubMember` (socios y el Gran Maestro), `ClubSuspicion`
(con `prefix` "CHESS_"), `ClubDoorman` (el portero), `ClubEvidence` y `ClubEvidenceSpot`, `KeyPot`, `DisguisePiece`
(tres piezas nuevas), `PlaceBuilder`, `ChaseCase` con un `SuspectCar` nuevo, `PlaceDraw` y `NpcSync`. Las partidas
copian la forma de `RestaurantOrders` y `SchoolClasses` (el host decide y avisa).

## El orden para hacerlo (un PR chico por paso)
1. El disfraz de socio: anteojos gruesos, chaleco de rombos y boina en una fila frente a los casilleros, y el look
   "chess" (2 de 3).
   Hecho así: 12 piezas en una novena fila a 5,3 m frente a los casilleros (anteojos negros gruesos con lentes de
   culo de botella, chaleco verde de rombos sobre camisa blanca con corbata marrón y boina marrón). Con 2 de 3,
   `is_disguised("chess")`; los anteojos del club de abuelos y la boina de mimo no cuentan. Correr la hace caer como
   cualquier disfraz **(propuesta)**.
2. El club en la ciudad (`--place=chess`): el salón con las mesas, la sala del torneo, la cafetería, la vitrina, el
   depósito y la oficina; los socios, el Gran Maestro y el portero.
   Hecho así: un lote nuevo en la cuadra (6, 1), al sur, de 24 x 20 m. El conserje (chaleco a cuadros, moño y
   cronómetro) está adentro de la entrada y solo deja pasar con 2 piezas de socio: todo el club es solo para socios.
   El salón tiene piso de damero, 8 mesas con su tablero en dos filas y la vitrina de trofeos en la pared oeste; al
   este, la cafetería con el mostrador y dos mesitas, y en su pared del fondo la puerta con llave de la oficina del
   Gran Maestro. Atrás, la sala del torneo con la tarima roja, la mesa del Gran Maestro y dos bancos, y al este el
   depósito de tableros. 6 socios (cárdigan marrón con anteojos y una pieza en la mano, o polera verde con rodete y
   termo) en 6 de los 16 lugares junto a las mesas por la semilla (los que sobran son para los policías), 2 de público
   mirando la tarima y el rival del Gran Maestro. El Gran Maestro Alfil (sombrero blanco de alfil, monóculo y el rey
   negro en la mano) en la tarima, mirando la puerta. Las sillas llegan con el paso 3 **(propuesta)**.
3. Los tableros: las piezas con física, el reloj de cada mesa y sentarse.
   Hecho así: cada mesa (también la del Gran Maestro) tiene un tablero de 8 x 8 con una partida a medias (torre,
   caballo, alfil, dama, rey y un peón de cada color, no las 32 piezas, para que haya poco objeto suelto), el reloj
   al lado y un banquito detrás de cada lugar. Las piezas son objetos con física: agarrar una y soltarla en otra
   casilla es una jugada, legal o no (el host avisa `moved`); tirarla del tablero también cuenta. El reloj cuenta 8 s
   del turno de un lado; E lo toca y el turno pasa al otro lado; si llega a 0, ese lado perdió por tiempo. "Sentarse"
   es pararse en el lugar frente a la mesa, con las manos libres para mover **(propuesta)**.
4. Las partidas: el desafío, los turnos con el reloj, los comentarios, el chisme y la sospecha.
   Hecho así: a los 20 s y después cada 45 s, si hay un policía en el club, un socio de una mesa con el lugar de
   enfrente libre lo desafía ("¡Tú, el nuevo! ¿Una partida?") y al policía le sale en pantalla. Tiene 15 s para pararse
   en ese lugar; si no, "¿Me dejas plantado?" y +20 a los socios del salón. La partida dura 60 s: el socio piensa 2 s,
   mueve una pieza suya a una casilla libre y toca el reloj; el policía tiene 8 s para mover una pieza con las manos y
   tocar el reloj (el socio comenta: "Interesante...", "¿El caballo vuela ahora?"; si movió una pieza ajena, "Esa pieza
   es mía, pero bueno..."). Tocar el reloj sin mover suma +10 y sigue; perder por tiempo +20, alejarse más de 1,5 m
   del lugar +30 y tirar 3 piezas del tablero +40, y la partida termina. Al final el socio dice "Buena partida. Rara,
   pero buena" (el chisme que ayuda con una prueba llega en el paso 5). Cada partida nueva arranca con el tablero
   acomodado **(propuesta)**.
5. Las pruebas y el caso (variante "chess"): el torneo, las 6 pruebas, el sueldo y el interrogatorio.
   Hecho así: la semilla elige 3 de las 6 pruebas (sin el video si no hay dos socios cerca, y nunca con el rival del
   torneo, que está jugando). El rey negro hueco (1,5 kg) está en el tablero de la tarima al lado del Gran Maestro y el
   maletín abierto con piezas huecas (6 kg) en el piso al lado de la tarima: se agarran. La planilla en código cuelga
   siempre en la pared de la cafetería ("PARTIDA DEL SÁBADO · 1. e4 = 4 diamantes · 2. Cf3 = 2 rubíes · 3. Ab5 =
   entrega en la mesa 8 · Jaque = la policía"), pero solo es prueba si salió (foto). La vitrina ahora tiene vidrio y
   se ven las 3 copas (E). La llave de la oficina está pegada con cinta debajo de la mesa 8 (E) y el libro de cuentas
   en el escritorio de la oficina (E). Al terminar bien una partida, el socio cuenta un chisme sobre la primera prueba
   que falta ("Las copas de la vitrina hacen tic tac. Muchos tic tac."), o solo "Buena partida" si ya están todas. El
   caso usa sus propios textos (cartel del comisario, objetivos, pistas, frases de Alfil al ser descubierto, el
   interrogatorio y la persecución a pie mientras no hay huida propia) **(propuesta)**.
6. La huida en el caballito, el sorteo de "Jugar" en octavos y online.

## Preguntas para Cristian (decisión 175)
1. **¿Hay que jugar de verdad, con desafíos cada 45 s y partidas con reloj donde se mueven las piezas con las manos
   (sin revisar si la jugada es legal)?** Recomiendo que sí: es lo que dice el caso ("hay que jugar mientras se
   espía"), y no pedir jugadas legales deja el chiste sin que haga falta saber ajedrez.
2. **¿Los policías se disfrazan de socio (anteojos gruesos, chaleco de rombos y boina, 2 de 3)?** Recomiendo que sí,
   para mantener la regla del disfraz.
3. **¿El Gran Maestro escapa en un caballito de calesita a motor que salta en L en las esquinas?** Recomiendo que sí:
   es lento pero salta, y es el chiste del caballo.

Mientras no respondas, se avanza con lo recomendado.
