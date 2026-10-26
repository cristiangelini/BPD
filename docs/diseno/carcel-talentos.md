# Cárcel 6.5: Concurso de talentos

Decisión 144 (propuesta). Caso de la cárcel ([carcel-motin.md](carcel-motin.md), fila 5 de la tabla). Todos los
números son (propuesta).

## La idea
La cárcel hace su concurso de talentos anual en el comedor, con escenario, telón y un cartel pintado a mano. El
director de la cárcel invitó a la comisaría a ser **el jurado**. Los presos están felices. Demasiado felices: cada
número del show es una distracción para que alguien se escape mientras todos miran el escenario. El chiste: **hay que
mirar el show y, a la vez, no mirarlo**.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, hoy son el jurado del concurso de talentos de la cárcel. Voten
   con cariño, pero no le saquen el ojo a nadie. El año pasado ganó un mago y no lo vimos nunca más".
2. **El comedor:** las mesas de la mitad oeste se corren y quedan 3 filas de bancos frente a un escenario nuevo
   contra la pared del fondo (la del pabellón), con telón rojo. Delante del escenario, la **mesa del jurado** con 4 sillas y 4
   carteles de puntaje (del 1 al 10). 12 presos en los bancos (el modelo del motín) y el presentador (un preso con
   moño y micrófono) arriba.
3. **Los números:** son 5, de 60 s cada uno, con 15 s de telón cerrado entre uno y otro: siempre el mago, el coro y
   el baile con humo, y 2 de los 5 números sin truco (el malabarista, el ventrílocuo, el de los platos chinos, la banda
   de cucharas y el poeta); la semilla elige cuáles 2 y el orden de los 5. El presentador anuncia cada uno ("¡Con
   ustedes... el Gran Ratoncini!").
4. **El jurado:** al final de cada número el presentador pide el voto: "¡Jurado, sus puntajes!". Durante 5 s tiene
   que haber al menos un policía sentado en la mesa del jurado (E en una silla para sentarse, E otra vez para
   pararse) y levanta un cartel con la rueda del mouse o con 1 a 9 y 0 para el 10. Si la mesa está vacía, el público
   se ofende: abucheo y **guerra de comida chica** de 20 s en los bancos (la del motín), que hay que parar como en el
   motín.
5. **Los trucos de fuga:** 3 de los 5 números esconden una fuga. Cada truco tiene su pista, si uno mira lo que no
   hay que mirar:
   - **El mago:** pide un voluntario del público, lo mete en una caja y lo hace "desaparecer". La caja tiene doble
     fondo y una trampa en el escenario que da a la cocina. E sobre la caja mientras está cerrada la abre y el
     voluntario sale avergonzado; si no, aparece corriendo en la cocina hacia la puerta de servicio.
   - **El coro:** canta fuerte (y muy mal) para tapar la sierra de un preso que corta los barrotes de una ventana del
     comedor. De cerca de la ventana se oye "ñic, ñic" debajo del canto; E sobre él lo atrapa.
   - **El baile con humo:** una máquina de humo llena el escenario y los bancos; dos presos se agachan y gatean hacia
     la puerta del patio. E sobre la máquina la apaga y el humo se va en 5 s.
   - Los otros números (malabarista, ventrílocuo, platos chinos, cucharas, poeta) son trucos falsos: tienen algo
     sospechoso (el muñeco del ventrílocuo "habla solo", las cucharas podrían servir para cavar) pero no esconden
     nada. Revisarlos no resta, pero el que está en el escenario se ofende y el número sigue.
6. **El que se escapa:** el que logra salir corre al portón del patio (como los de la lavandería y el corte de luz).
   Se lo esposa y se lo lleva del brazo a la celda de castigo. Si llega al portón, cuenta como escapado.
7. **El final:** después del quinto número el presentador lee el ganador (el que tuvo más puntaje del jurado; con
   empate, el último). El ganador llora de emoción. **Se gana** cuando termina el show con menos de 3 escapados;
   **se pierde con 3 escapados**.
8. **El sueldo:** 600, 100 menos por cada escapado, 25 más por cada uno en la celda de castigo y 20 más por cada
   número votado (con alguien en la mesa del jurado a tiempo). Cuota propia de 400, como las otras cárceles.

## Lo que cambia con la semilla
Qué 2 números sin truco salen y en qué orden van los 5, quién es el voluntario del mago, qué ventana sierra
el del coro y quiénes gatean en el humo.

## Lo que se reusa
- La cárcel y su comedor (`PrisonLevel`), los presos del motín (modelo `npc_preso`), la guerra de comida
  (`PrisonRiot`) para el público ofendido.
- El que corre al portón (`BlackoutInmate`), las esposas y llevarlo a la celda de castigo (`BlackoutEscort`).
- E sobre algo para revisarlo (los escondites del túnel y los carritos de la lavandería) y el globito de texto.
- Lo nuevo: el escenario con telón, la mesa del jurado con sillas y carteles, el presentador, los 8 números, la caja
  del mago, la sierra de la ventana y la máquina de humo.

## Atajos del panel de pruebas (cuando exista)
- Abrir el concurso de talentos (`--place=prison_talent`).
- Saltar al número siguiente.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. El comedor con escenario, telón, bancos y la mesa del jurado (`--place=prison_talent`), los 12 presos sentados y
   el presentador.
3. Los números: el show con sus 5 números de la semilla, el telón y el voto del jurado (sentarse y levantar cartel).
4. El público ofendido: la guerra de comida chica si la mesa del jurado está vacía.
5. Los trucos de fuga: el mago, el coro y el humo, con sus pistas y el que corre al portón.
6. El caso: el comisario, la planilla, el sueldo, la cuota, perder con 3 y el sorteo en Jugar (`PlaceDraw.PRISONS`,
   en séptimos).
7. Online: los presos, el presentador, el show, el jurado, los trucos y el final.

## Preguntas para Cristian
1. **¿Los policías son el jurado** y alguien tiene que estar sentado en la mesa del jurado al final de cada número?
   Recomendado: sí, así el equipo tiene que repartirse entre mirar el show y cuidar la sala.
2. **¿Solo 3 de los 5 números esconden una fuga** y los otros son trucos falsos con algo sospechoso? Recomendado: sí,
   así no alcanza con desconfiar de todo y hay que mirar las pistas.
3. **¿Si la mesa del jurado queda vacía al votar, el público arma una guerra de comida chica** (la del motín)?
   Recomendado: sí, es el castigo por no votar y reusa lo que ya está hecho.

## Hecho así
- **Paso 2:** `--place=prison_talent` (`scenes/levels/prison_talent.tscn`, `PrisonLevel.variant = "talent"`). Sin las
  3 mesas del oeste, el comedor tiene el escenario (`TalentStage`: tarima de 6 x 2,5 m con escalón, telón rojo de dos
  mitades que se abren a los costados y el cartel pintado), la mesa del jurado con sus 4 sillas (`JuryChair`: E para
  sentarse mirando al escenario y E para pararse) y 3 bancos con los 12 presos sentados mirando el show
  (`TalentInmate`); arriba, el presentador con moño y micrófono. `TalentPlan` sortea el show: siempre el mago, el coro
  y el humo, más 2 de los otros 5, en el orden de la semilla. Capturas: `paso2-comedor.png`, `paso2-jurado.png` y
  `paso2-presentador.png` en `carcel-talentos/`.
- **Paso 3:** el show (`TalentPlan`). Empieza cuando el primer policía entra al comedor: el presentador da la
  bienvenida (6 s) y por cada número lo anuncia con el telón cerrado (4 s), lo abre 60 s con los del número adelante
  (el mago con galera, el coro de 3, el malabarista con sus pelotas, el ventrílocuo con el señor Botones...) diciendo
  su frase cada 8 s, y pide los puntajes 5 s: el público aplaude y sube el cartel de cada policía sentado en el jurado.
  Después cierra el telón 15 s. Sentado en una silla del jurado, R cambia el puntaje del cartel (1 a 10). Al final
  nombra al ganador (más puntos; con empate, el último), que sale a llorar de emoción. Capturas: `paso3-numero.png`,
  `paso3-voto.png` y `paso3-ganador.png`.
- **Paso 4:** el público ofendido. Si nadie está sentado en el jurado cuando el presentador pide los puntajes, dice
  que el público está ofendido y 6 presos de los bancos se paran abucheando ("¡Fraude! ¡Jurado vendido!") y le tiran
  comida del comedor (puré, gelatina, pollo y yogur, como en el motín) al policía más cercano en el comedor, cada 2 a
  4 s, durante 20 s. E sobre uno lo calma y se vuelve a sentar ("Bueno, bueno... pero voten"); con todos calmados se
  termina antes. El show sigue mientras tanto. Captura: `paso4-abucheo.png`.
- **Paso 5:** los trucos de fuga (`TalentTricks`, `TalentProp`). La semilla elige el voluntario del mago, el que
  sierra, los 2 que gatean y cuál de las 3 ventanas del muro oeste del comedor. **El mago** pide un voluntario a los
  8 s, lo mete en su caja violeta con estrellas a los 12 s y a los 40 s "desaparece": E sobre la caja cerrada lo saca
  colorado; si no, sale corriendo en la cocina. **El coro**: a los 5 s uno del público se va a una ventana y sierra
  los barrotes 40 s ("ñic, ñic", que se oye a 4 m); E sobre él lo agarra y va directo a la celda de castigo, y si
  termina los barrotes desaparecen y sale por afuera del muro. **El humo**: la máquina llena el escenario y los
  bancos, y a los 10 s dos del público gatean hacia la puerta del patio; E sobre la máquina la apaga, el humo se va
  en 5 s y los que gateaban vuelven a su lugar ("Yo... buscaba el baño"); si llegan a la puerta salen corriendo. Los
  que corren van al portón como los de la lavandería: esposados y llevados a la celda de castigo cuentan como
  atrapados, en el portón como escapados. Capturas: `paso5-mago.png`, `paso5-sierra.png`, `paso5-humo.png` y
  `paso5-humo-apagado.png`.
- **Paso 6:** `TalentCase` (`scripts/case/prison/talent_case.gd`): el comisario lo cuenta en su oficina y Q abre la
  planilla: llegar al final del show (número tal de 5), qué hay en el escenario (o telón cerrado, o que el show
  empieza al entrar al comedor), los números votados, los escapados (con 3 se pierde) y, de extra, los de la celda de
  castigo. Se gana cuando termina el show: 600, 100 menos por escapado, 25 más por cada uno en castigo y 20 más por
  número votado. Cuota 400. En Jugar entra en el sorteo de cárceles (`PlaceDraw.PRISONS`, ahora en séptimos).
  Captura: `paso6-planilla.png`.
