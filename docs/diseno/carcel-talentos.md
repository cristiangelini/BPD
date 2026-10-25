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
2. **El comedor:** las mesas largas se corren a los costados y quedan 3 filas de bancos frente a un escenario nuevo
   contra la pared de la cocina, con telón rojo. Delante del escenario, la **mesa del jurado** con 4 sillas y 4
   carteles de puntaje (del 1 al 10). 12 presos en los bancos (el modelo del motín) y el presentador (un preso con
   moño y micrófono) arriba.
3. **Los números:** son 5, de 60 s cada uno, con 15 s de telón cerrado entre uno y otro. La semilla elige 5 de 8:
   el mago, el coro, el baile con humo, el malabarista, el ventrílocuo, el de los platos chinos, la banda de cucharas
   y el poeta. El presentador anuncia cada uno ("¡Con ustedes... el Gran Ratoncini!").
4. **El jurado:** al final de cada número el presentador pide el voto: "¡Jurado, sus puntajes!". Durante 5 s tiene
   que haber al menos un policía sentado en la mesa del jurado (E en una silla para sentarse, E otra vez para
   pararse) y levanta un cartel con la rueda del mouse o con 1 a 9 y 0 para el 10. Si la mesa está vacía, el público
   se ofende: abucheo y **guerra de comida chica** de 20 s en los bancos (la del motín), que hay que parar como en el
   motín.
5. **Los trucos de fuga:** 3 de los 5 números esconden una fuga (la semilla elige cuáles). Cada truco tiene su
   pista, si uno mira lo que no hay que mirar:
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
Qué 5 números salen y en qué orden, cuáles 3 esconden una fuga, quién es el voluntario del mago, qué ventana sierra
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
