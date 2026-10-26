# BPD · Protección del político: Partido de fútbol benéfico (propuesta, 26/10)

Cuarta variante de la protección de un político ([casos.md](casos.md), 9.5), sobre la base del acto en la plaza
([proteccion-politico.md](proteccion-politico.md), decisión 103), la caminata por el mercado
([politico-mercado.md](politico-mercado.md), decisión 120) y el puente ([politico-puente.md](politico-puente.md),
decisión 178). Todos los números son **(propuesta)** hasta probarlos jugando. Esta variante es la decisión 179, y las
que salgan de las preguntas van de la 230 a la 239.

## La idea
El diputado **Pompeyo Lustre** juega un partido benéfico de fútbol 7 contra **Los Veteranos del Barrio** para la foto
con la copa. Juega muy mal y se tira al piso como si lo hubieran matado cada vez que alguien lo roza. Los 4 policías
son su custodia y además juegan en su equipo, con pechera. El rival, el concejal **Tito Barullo**, compró al árbitro y
metió en los Veteranos al **Tanque**, un señor de 120 kg que va a buscar las piernas del diputado. El chiste
cooperativo, bien físico: le pasas la pelota a un diputado que no le pega a nada, te tiras delante del Tanque para
frenarlo y llevas al diputado en camilla al banco y de vuelta a la cancha mientras grita.

## La historia del comisario
"Novatos, el diputado Lustre juega un partido benéfico. Ustedes juegan con él, de custodia y de compañeros. Que meta un
gol para la foto y que salga entero. En ese orden, dice él. En el otro, digo yo."

## Cómo es el caso
1. **El lugar:** una cancha de fútbol 7 del barrio en un lote nuevo de la ciudad, con pasto, líneas de cal, dos arcos
   con red, una tribuna chica con unos 14 vecinos, el banco de cada equipo, una camilla y un puesto de
   salchichas. La copa está en una mesa al costado.
2. **El partido:** 2 tiempos de 3 minutos (el reloj del caso, como el discurso de la plaza). En el equipo del diputado
   juegan él, los policías que haya y completan 2 asesores de traje que no corren. Los Veteranos son 7, con el Tanque.
   Los veteranos corren despacio detrás de la pelota y patean al arco; el arquero rival ataja lo que le llega flojo.
3. **La pelota:** una pelota con física. Un policía la patea con clic izquierdo cuando la tiene a menos de 1 m (fuerte
   si mantiene el clic, como el ariete). Agarrarla con la mano es "mano": el árbitro cobra tiro libre para los
   Veteranos.
4. **El diputado:** corre hacia la pelota cuando está cerca y le pega para cualquier lado (1 de cada 3 va al arco). Si
   le pasan la pelota bien cerca del arco rival, tiene más chances. Cada vez que alguien lo toca se tira al piso
   gritando y no se levanta solo: hay que llevarlo en la camilla (2 policías, como la caja fuerte) hasta el banco, ahí
   se cura en 5 s y vuelve. Mientras está tirado el partido sigue.
5. **El Tanque:** cada tanto va directo al diputado a barrerlo. Se lo ve venir (corre con los brazos abiertos y grita
   "¡AHÍ VOY!"). Un policía que se le pone delante lo frena y los dos caen al pasto.
   Si llega, el diputado sale volando: eso es una **lesión de verdad**.
6. **El árbitro:** cobra todo contra el equipo del diputado (manos que no fueron, tiros libres al lado del arco). Pistas:
   un sobre con plata que se le asoma del bolsillo, un pin de campaña de Barullo en la gorra, y cada tanto mira a la
   tribuna donde está Barullo y le hace un pulgar arriba. Esposado, se lo escolta al patrullero y un policía agarra su
   silbato: desde ahí no se cobra nada en contra.
7. **Se gana** si el diputado mete al menos un gol antes del final (la foto con la copa). Sueldo de 600: 100 menos por
   cada lesión de verdad, 50 más si el partido lo gana el equipo del diputado y 100 más si el árbitro quedó detenido.
   Cuota propia de 400, como la plaza.
8. **El final:** si el árbitro sigue suelto al final, sale corriendo y se sube a la moto de Barullo (persecución
   embebida, decisión 96). Atrapado, cuenta como detenido.

## Lo que se reusa
- El diputado, su modelo y sus quejas (decisión 103); cargar de a dos (la caja fuerte); esposas y escolta al patrullero; la persecución embebida (ChaseCase.begin); el público del acto.
- Lo nuevo: la cancha, la pelota que se patea, el partido con su reloj y su marcador, los veteranos, el Tanque, la
  camilla, el árbitro comprado y la moto de Barullo.

## El orden para hacerlo (un PR chico por paso)
1. La cancha en la ciudad: pasto, líneas, arcos con red, tribuna, bancos, camilla y la mesa con la copa.
2. La pelota y la patada: patear con clic, la mano, el gol y el marcador.
3. El partido: el reloj de 2 tiempos, los veteranos y el arquero, los asesores, el diputado que juega mal.
4. Las caídas del diputado, la camilla, el Tanque y la lesión de verdad.
5. El árbitro comprado: cobra en contra, pistas, esposarlo y el silbato; el caso, sueldo y cuota.
6. La moto de Barullo y el sorteo de Jugar (plaza, mercado, puente y cancha).
7. El online.

## Preguntas para Cristian
1. **¿Qué pasa con las lesiones de verdad del diputado?** Recomendado: cada una cuesta 100 de sueldo, y a la tercera
   se va en ambulancia y el caso se pierde.
2. **¿Los policías patean la pelota?** Recomendado: sí, con clic izquierdo cerca de la pelota (mantener para patear
   fuerte); agarrarla con la mano es mano. Si no, juegan solo empujándola con el cuerpo.
3. **¿Hay un culpable para esposar?** Recomendado: sí, el árbitro comprado por el concejal Barullo, que huye en su
   moto si no lo atrapan.

## Hecho así
- **Paso 1 (la cancha):** `FootballPitch` (`scenes/levels/football_pitch.tscn`, `--place=football`) es la ciudad entera
  con el lote `football_pitch`, que llena la cuadra (4, 4) como el parque del puente (`"park": true`). La cancha mide
  44 x 28 m a lo largo de x, con el centro en z = -2: pasto en 8 franjas, líneas de cal, círculo central, áreas de 6 m
  y punto de penal. Hay un arco de 6 x 2 m en cada punta (`goals`, modelo `football_goal`) con cuerpos gruesos en la red
  para que la pelota quede adentro. Al norte está la tribuna de 3 escalones; al sur, hacia la calle, los dos bancos
  (`team_bench`), la camilla (`stretcher`), la mesa con la copa (`football_cup`), el puesto de salchichas, la pancarta
  "Partido benéfico" y el cartel. Capturas en `/mnt/project-files/futbol/paso1-*.png`.
- **Paso 2 (la pelota y el gol):** `FootballBall` (`pitch.ball`, modelo `football_ball`) pesa 450 g, rebota, rueda y
  tiene colisión continua. Con la pelota a menos de 1,3 m adelante de los pies, el clic izquierdo patea en vez de
  agarrar (`Grabber.start_kick`/`end_kick`): de 7 m/s si es un toque a 20 m/s si se mantiene 0,8 s, hacia donde mira
  el policía y un poco hacia arriba (más si mira arriba). E es un pase de 6 m/s por el piso. Agarrarla con las manos
  es mano (`handball`). `FootballScore` (`pitch.score`): el equipo del diputado ataca el arco este y los Veteranos el
  oeste; la pelota entera pasando la línea entre los palos y bajo el travesaño es gol (`scored(team, by)`, con
  `last_touch`), y a los 3 s vuelve al centro. Si sale por un costado o por el fondo, al segundo vuelve a 1 m adentro de
  donde salió. Arriba de la pantalla, el marcador "LUSTRE 0 - 0 VETERANOS". Captura en
  `/mnt/project-files/futbol/paso2-gol.png`.
- **Paso 3 (el partido):** `FootballMatch` (`pitch.match_clock`) arranca cuando un policía pisa la cancha: 2 tiempos de
  3 minutos con 10 s de descanso, y el reloj abajo del marcador ("Tiempo 1 · 2:57"). Los Veteranos son 6 jugadores y
  un arquero (`FootballPlayer`, pechera roja): el más cerca de la pelota va a buscarla y le pega al arco oeste (de 11 a
  15 m/s, con 3,5 m de error); los demás vuelven a su lugar. El arquero se mueve sobre la línea siguiendo la pelota y
  despeja lo que le llega a menos de 1,3 m y más lento que 12 m/s. Los 2 asesores de traje (pechera amarilla) caminan a
  1,2 m/s y empujan lo que les llega. El diputado (`FootballLustre`, pechera amarilla) corre a la pelota si está a
  menos de 9 m y le pega para cualquier lado: 1 de cada 3 va al arco, 1 de cada 2 a menos de 14 m del arco, y grita
  algo. Captura en `/mnt/project-files/futbol/paso3-partido.png`.
- **Paso 4 (caídas, camilla y el Tanque):** si un veterano se le acerca a menos de 0,95 m, el diputado se tira al
  pasto gritando ("¡Me mataron!") y no se levanta solo; después de levantarse tiene 3 s sin caerse. La camilla
  (`FootballStretcher`, `pitch.stretcher`) vacía pesa 10 kg y la lleva uno; puesta a menos de 1,6 m del diputado, él se
  sube y pasa a pesar 50 kg: hace falta cargarla de a dos. A menos de 2,5 m de su banco (el oeste) se baja, se cura en
  5 s y vuelve a jugar. El Tanque es el sexto veterano, más grande (`pitch.match_clock.tank`): juega como los otros y
  cada 25 s corre a 5 m/s hacia el diputado con los brazos abiertos gritando "¡AHÍ VOY!" (6 s como mucho). Un policía
  a menos de 1,1 m lo frena: los dos caen (el Tanque 3 s, el policía 1,5 s). Si llega al diputado, lo hace volar y es
  una lesión de verdad (`injured`, `injuries`); qué pasa con el sueldo y a la tercera queda para el paso 5. Captura en
  `/mnt/project-files/futbol/paso4-camilla.png`.
- **Paso 5 (el árbitro y el caso):** el árbitro (`FootballReferee`, `pitch.referee`, modelo `npc_arbitro`) sigue la
  jugada 6 m al sur de la pelota y cada 20 s cobra tiro libre para los Veteranos a 8 m de nuestro arco (`call_foul`);
  una mano de un policía también. Pistas: con E le asoma el sobre con plata del bolsillo ("envelope"), y cada 15 s le
  hace un pulgar arriba al concejal Barullo (`pitch.barullo`, modelo `npc_concejal`, en el escalón del medio de la
  tribuna), que lo ve el policía a menos de 12 m ("thumbs"); el pin verde de Barullo en la gorra está siempre. Esposado,
  E lo lleva al patrullero (`OwnerEscort`) y ya no cobra nada. `FootballCase` (`pitch.case`): el comisario lo cuenta,
  Q abre la planilla, y se resuelve si el diputado mismo metió al menos un gol (un gol de un policía no es foto). Al
  final del partido termina el turno. Sueldo 600, menos 100 por lesión de verdad, más 50 si el equipo del diputado ganó
  y más 100 si el árbitro está en el patrullero; cuota 400. A la tercera lesión se lo lleva la ambulancia y el caso se
  pierde (pregunta 1, recomendado). Captura en `/mnt/project-files/futbol/paso5-arbitro.png`.
- **Paso 6 (la moto de Barullo y el sorteo):** la moto verde de campaña de Barullo (`pitch.moto`, modelo
  `barullo_scooter`, con banderín) espera estacionada en la calle de enfrente. Si al final del partido el árbitro sigue
  suelto, se sube y escapa a 45 km/h, doblando bien en las esquinas (`ChaseCase.begin`, decisión 96); atrapado, cuenta
  como detenido y suma los 100. Jugar sortea la protección del político en cuartos: plaza, mercado, puente y cancha. El
  online queda para un paso 7, como en el puente. Captura en `/mnt/project-files/futbol/paso6-moto.png`.
- **Paso 7 (online):** el caso del anfitrión decide y el de los invitados lo sigue (`CaseSync`, `snapshot`): el reloj y
  el tiempo del partido, el marcador, el diputado en el piso y sus lesiones, las pistas, el final y la huida en la moto.
  El juego (veteranos, arquero, Tanque, árbitro y diputado) solo corre en el anfitrión; los jugadores y el árbitro
  llegan por `NpcSync`, con el Tanque cargando o caído y el árbitro esposado. La pelota y la camilla van por
  `PropSync` y la patada de un invitado por `ActionSync`. Las pecheras se ponen en todas las PCs cuando arranca el
  partido. Pruebas en `test_online_football`.
