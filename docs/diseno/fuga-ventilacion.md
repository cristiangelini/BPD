# La fuga: por la ventilación (propuesta, 25/10)

Quinta variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.1: "con un compañero que no entra").
Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y de las otras tres
([fuga-limpieza.md](fuga-limpieza.md), decisión 150; [fuga-perro.md](fuga-perro.md), decisión 151;
[fuga-tunel.md](fuga-tunel.md), decisión 152): celdas con candado, una sola fuga por partida, salir en el patrullero,
"¡Fugados!" y perder a la tercera captura. Los números son **(propuesta)** hasta probarlos jugando.

## La idea
Es de noche y el guardia está despierto en su escritorio, sin donas, mirando las celdas. En la pared del fondo de cada
celda, arriba, hay una rejilla de ventilación floja. Por el ducto se puede gatear hasta la oficina del comisario, que
de noche está vacía. El problema: uno de los cuatro, el grandote, no entra. Se traba con medio cuerpo adentro y las
piernas pataleando afuera. Los que pasan tienen que salir de la oficina, robar la llave del tablero que está detrás
del guardia y volver a abrirle la celda.

El chiste cooperativo: el grandote no se aburre, porque desde la celda es el que distrae al guardia (cantar, gritar,
tirar cosas) mientras los otros cruzan la sala a sus espaldas.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una, con las rejas cerradas. El guardia en su escritorio mirando
   las celdas, sin la llave: las llaves de las celdas cuelgan del tablero de llaves de la pared, detrás de él. Aviso:
   "Una rejilla floja arriba... ¿entramos todos por ahí?"
2. **La rejilla:** a 2,2 m del piso, en la pared del fondo de cada celda. Se llega subiéndose a la cucheta. Tiene 4
   tornillos y cada uno sale con 4 toques de E, uno cada medio segundo (con la uña). Sin tornillos se cae al piso y queda el agujero.
3. **El grandote:** con 2 o más policías, la semilla elige uno que no entra. Si intenta meterse en el ducto queda
   trabado 4 s ("¡Estoy atorado!") y vuelve a caer a la celda; un compañero lo puede empujar o tirar de él, pero no
   pasa igual. Jugando solo, nadie es el grandote.
4. **El ducto:** con E en el agujero el policía se mete. Adentro se gatea despacio (la mitad de lo normal) por un
   ducto angosto que pasa arriba del techo: desde cada celda, por encima de la sala de guardia, hasta la rejilla del
   techo de la oficina del comisario. En el medio hay un desvío sin salida (la semilla elige de qué lado está).
5. **El ruido en el ducto:** gatear despacio no hace ruido. Correr (Shift) adentro del ducto hace "bong, bong": si el
   policía está encima de la sala de guardia, el guardia mira al techo y le sube la sospecha 15 por segundo ("¿Hay
   ratas en el techo?").
6. **La oficina:** la rejilla del techo se patea desde arriba y el policía cae a la oficina. La puerta de la oficina da
   a la sala de guardia, a unos 10 m de la espalda del guardia.
7. **El tablero de llaves:** en la pared de atrás del escritorio. Llegar sin que el guardia te vea y agarrar la llave
   de la celda del grandote con E. El guardia mira las celdas y gira la cabeza de a ratos; mira para atrás si oye algo
   (un ruido o un grito de lejos), así que el grandote lo tiene que distraer hacia las celdas.
8. **Abrir y salir:** con la llave se abre la celda (como en la dona). Todos al patrullero, a 25 m del
   estacionamiento: "¡Fugados!".
9. **La captura:** el guardia ve a alguien fuera de las celdas o llega a 100 de sospecha: todos vuelven a las celdas,
   la llave vuelve al tablero y las rejillas que estaban sacadas se quedan sacadas (no las vuelve a atornillar: "Mañana
   las arreglo"). A la tercera llama al comisario, que llega en pijama: "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- Quién es el grandote (uno de los policías, con 2 o más).
- De qué lado del ducto está el desvío sin salida.
- En qué gancho del tablero está la llave buena (hay 6 ganchos y 6 llaves; las otras son del depósito, del baño...).
  La equivocada no abre la celda ("Esta es la del baño").
- Las frases: 10 o más del guardia mirando el techo, del grandote trabado y de las llaves equivocadas, con `tr()`.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, el grandote incluido, a 25 m del estacionamiento. Sigue el turno
  siguiente sin la plata del turno fallado (decisión 99).
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66): la presión es la mirada del guardia.

## Lo que se reusa
`JailbreakLevel` (celdas, capturas, salida, final, guardado y el sorteo de variantes), `NightGuard` (la mirada, la
sospecha, los ruidos que lo distraen, dormirse con el canto de los cuatro, que acá no sirve porque el grandote solo no
alcanza), `CellKey` y las puertas de las celdas. Nuevo: la rejilla con tornillos, el ducto, el grandote y el tablero
de llaves.

## Online
Todo lo decide el anfitrión: los tornillos, quién es el grandote, quién está en el ducto, el ruido, la sospecha, qué
llave se sacó y las capturas. El guardia va por `NpcSync`; la rejilla, la llave y el tablero, por `PropSync` y
`NpcSync`. El que se mete en el ducto se mueve solo, como siempre, y el anfitrión lo ve.

## Atajos del panel de pruebas (cuando exista)
- Empezar la fuga por la ventilación (`--jailbreak=vent`).
- Sacar todos los tornillos de una rejilla ya.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo en quintos (`--jailbreak=vent`), el guardia despierto, la rejilla con tornillos de cada celda y el
   grandote (modelos en `tools/modelgen`).
2. El ducto: meterse, gatear, el grandote trabado, el desvío, la rejilla de la oficina y el ruido al correr.
3. El tablero de llaves detrás del guardia, la llave buena, abrir la celda, salir, frases y online.

## Preguntas para Cristian
1. ¿La fuga sortea en quintos entre dona, limpieza, perro, túnel y ventilación? **Recomiendo sí:** las cinco
   comparten celdas, salida y final.
2. ¿El grandote lo elige la semilla y no los jugadores? **Recomiendo sí:** si se elige, nadie quiere serlo; sorteado
   es parte del chiste, y desde la celda tiene trabajo (distraer al guardia).
3. ¿Que correr en el ducto haga ruido y el guardia mire al techo? **Recomiendo sí:** obliga a gatear despacio y le da
   tensión al ducto, que si no es solo un pasillo.

## Cómo quedó el paso 1
- `--jailbreak=vent` fuerza la variante; el sorteo de la fuga ahora es en quintos.
- `VentGuard` (scripts/npc/vent_guard.gd): despierto, sin donas y sin la llave.
- `VentGrille` en la pared del fondo de cada celda, a 2,2 m, encima de la cucheta: desde el piso dice "súbete a la
  cucheta"; arriba, cada E da una vuelta al tornillo (una cada 0,5 s) y con 4 vueltas sale. Sin tornillos se cae al
  piso y queda el agujero oscuro.
- `JailbreakLevel.big_cop()`: el grandote, sorteado por la semilla entre los policías por su uniforme (igual en todas
  las PCs); jugando solo no hay.
- Modelos `vent_grille` y `vent_hole` en `tools/modelgen/models/vent.js`. Pruebas en `test_vent_grille.gd`.

## Cómo quedó el paso 2
- Con la rejilla sacada, E desde la cucheta mete al policía en el ducto (`VentDuct`), arriba del techo: un tramo largo
  sobre las celdas y la sala de guardia y tres desvíos hacia la oficina del comisario. Solo uno (la semilla elige)
  termina en la rejilla del techo de la oficina; los otros dos son ciegos.
- Adentro se gatea agachado (`Cop.crawling`): la mitad de lo agachado, y no se puede parar porque el techo es bajo.
  Correr (Shift) adentro sí se puede, pero es un "bong": el anfitrión lo oye por la velocidad, y si está a 15 m del
  guardia (`VentGuard.heard_duct`) mira al techo y la sospecha sube 15 por segundo mientras dure.
- El grandote se queda atorado 4 s ("Tú no entras: distrae al guardia desde la celda") y no sube.
- En el ducto, encima de cada celda, hay una rejilla para volver a bajar; la de la oficina se patea y te deja en la
  oficina. Una captura también baja a los del ducto a las celdas, y las rejillas sacadas quedan sacadas.
- 9 textos nuevos en es, en y pt. Pruebas en `test_vent_duct.gd`.
