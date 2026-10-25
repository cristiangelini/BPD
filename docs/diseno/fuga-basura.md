# La fuga: en el camión de la basura (propuesta, 25/10)

Sexta variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.5: "escapar en el camión de la basura").
Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y de las otras cuatro
([fuga-limpieza.md](fuga-limpieza.md), [fuga-perro.md](fuga-perro.md), [fuga-tunel.md](fuga-tunel.md),
[fuga-ventilacion.md](fuga-ventilacion.md), decisiones 150 a 153): celdas con candado, una sola fuga por partida,
salir en el patrullero, "¡Fugados!" y perder a la tercera captura. Los números son **(propuesta)** hasta probarlos
jugando.

## La idea
Es de noche y es noche de basura. El guardia, que odia esa parte del trabajo, pasa cada tanto por las celdas con una
bolsa de consorcio gigante, vacía el tacho de cada celda, arrastra la bolsa hasta el contenedor de la vereda y vuelve
quejándose. A cierta hora pasa el camión de la basura con Don Ruperto, el recolector, que vacía el contenedor y se va.

El plan: meterse en la bolsa. El guardia arrastra la bolsa (con un policía adentro) hasta el contenedor, el camión se
lleva el contenedor entero y el policía cae en la esquina, afuera. Pero el guardia cuenta presos en cada ronda, y una
bolsa que pesa como un policía es sospechosa.

El chiste cooperativo: los que quedan adentro arman muñecos con la almohada y la frazada para que la cuenta dé bien, y
los que salieron vuelven a buscar la llave para los que no entraron en ninguna bolsa.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una, con las rejas cerradas. El guardia en su escritorio con la
   llave en el cinturón. Aviso: "Huele a basura... ¿hoy pasa el camión?"
2. **La ronda de la basura:** cada 60 a 90 s (la semilla elige), el guardia se levanta, abre la reja de una celda
   (alterna), entra, deja una bolsa gigante abierta en el piso, vacía el tacho adentro, cuenta los presos de esa celda,
   cierra la bolsa y se la lleva arrastrando. Mientras está en la celda, la reja queda abierta pero él está en la
   puerta: salir corriendo es una captura.
3. **Meterse en la bolsa:** con la bolsa abierta en el piso, E (agachado) mete al policía adentro. Adentro no se ve
   nada y no se puede mover; E otra vez para salir. Una sola persona por bolsa.
4. **La cuenta:** el guardia cuenta los presos de la celda antes de llevarse la bolsa. Si falta uno, sospecha +40 y
   mira la celda 5 s ("¿Dónde está el otro?"). Un muñeco en la cucheta engaña la cuenta: E en la cucheta con las manos
   vacías arma el bulto con la almohada y la frazada (3 s). El muñeco cuenta como un preso, pero si el guardia lo mira
   de cerca más de 3 s, se da cuenta: captura.
5. **El peso:** una bolsa con un policía pesa. El guardia la arrastra la mitad de rápido y se queja ("¿Qué comieron
   hoy?"). Si en la misma noche arrastra dos bolsas pesadas seguidas, sospecha +30.
6. **El contenedor:** en la vereda de la comisaría, al lado del estacionamiento. El guardia tira la bolsa adentro y
   vuelve. El que está en la bolsa puede salir del contenedor (E), pero el guardia ve la vereda por la ventana.
7. **El camión:** pasa a los 3 minutos y después cada 4 (la semilla mueve un poco las horas). Don Ruperto baja,
   engancha el contenedor y lo vacía en el camión. Los policías que están adentro del contenedor (en bolsa o no) se
   van con la basura: el camión dobla la esquina y los deja caer, sucios, a 40 m de la comisaría ("¡Fugados... más o
   menos!"). Si Don Ruperto ve a alguien moverse en el contenedor, avisa al guardia: captura.
8. **Afuera:** los que salieron están libres en la calle. Pueden volver a la comisaría por la puerta de adelante
   (el guardia los puede ver) para sacarle la llave del cinturón con el palo de la dona, o esperar el próximo camión.
9. **Salir:** todos en el patrullero, a 25 m del estacionamiento: "¡Fugados!".
10. **La captura:** a 100 de sospecha, o si lo descubre: todos vuelven a las celdas, los muñecos se deshacen y la bolsa
    que estaba arrastrando se rompe ("¡Esto no es basura!"). A la tercera llama al comisario: "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- Cada cuánto hace la ronda (60 a 90 s) y por qué celda empieza.
- A qué hora exacta pasa el camión (3 min ± 30 s, y después cada 4 ± 30 s).
- Qué hay en los tachos (cáscaras, el diario, una dona mordida) y las quejas del guardia y de Don Ruperto: 10 o más
  frases con `tr()`.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento.
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66): el camión vuelve a pasar.

## Lo que se reusa
`JailbreakLevel`, `NightGuard` (la mirada, la sospecha, la llave del cinturón que se pesca con el palo), la caminata
del comisario madrugador para la ronda y la del guardia del túnel para ir a mirar, `PatrolCar` y los autos de la
ciudad para el camión. Nuevo: la bolsa gigante, el muñeco de la cucheta, el contenedor, el camión y Don Ruperto.

## Online
Todo lo decide el anfitrión: la ronda, quién está en qué bolsa, los muñecos, la cuenta, el contenedor y el camión.
El guardia, Don Ruperto y el camión van por `NpcSync`; las bolsas y el contenedor, por `NpcSync` con su estado.

## Atajos del panel de pruebas (cuando exista)
- Empezar la fuga de la basura (`--jailbreak=garbage`).
- Que pase el camión ya.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo en sextos (`--jailbreak=garbage`), el guardia de la basura, la ronda (abrir, la bolsa, cerrar) y los
   modelos (bolsa, tacho, contenedor).
2. Meterse en la bolsa, la cuenta, el muñeco de la cucheta y el peso.
3. El contenedor, el camión con Don Ruperto, caer en la esquina, volver, salir, frases y online.

## Preguntas para Cristian
1. ¿La fuga sortea en sextos entre las seis variantes? **Recomiendo sí:** todas comparten celdas, salida y final.
2. ¿Los que se van en el camión quedan libres afuera y la fuga se gana igual en el patrullero, con todos? **Recomiendo
   sí:** así los de afuera vuelven a ayudar a los que quedaron, que es el chiste cooperativo.
3. ¿El guardia cuenta presos en cada ronda y se engaña con un muñeco de almohada en la cucheta? **Recomiendo sí:** le
   da trabajo al que se queda y es un clásico de las fugas.

## Cómo quedó el paso 1
- `--jailbreak=garbage` fuerza la variante; el sorteo de la fuga ahora es en sextos.
- `GarbageGuard` (scripts/npc/garbage_guard.gd): despierto, sin donas y con la llave en el cinturón. Cada 60 a 90 s
  rezonga, va a una celda (una y después la otra), la abre, entra, deja la bolsa gigante abierta en el piso
  (`GarbageBag`), vacía el tacho 4 s ("Contra la pared, que vacío el tacho"), la anuda, sale arrastrándola, cierra la
  celda con llave, la lleva por la puerta del frente al contenedor de la vereda (`Dumpster`) y vuelve a su escritorio.
  Mientras da la vuelta sigue mirando.
- Una captura en plena ronda lo deja en el escritorio con las celdas cerradas y la bolsa se va.
- Modelos `trash_bin`, `garbage_bag` y `dumpster` en `tools/modelgen/models/garbage.js`. 6 textos nuevos en es, en y
  pt. Pruebas en `test_garbage_round.gd`.

## Cómo quedó el paso 2
- Con la bolsa abierta en el piso, agachado y E te metes adentro (`GarbageBag.hider`, una persona por bolsa): no te
  ve nadie, no chocas con nada y vas a donde vaya la bolsa. E otra vez para salir. Por ahora desde adentro se sigue
  viendo; la pantalla a oscuras queda para el paso 3.
- La cuenta: vaciado el tacho, el guardia se da vuelta y mira la celda 1,5 s. Sabe cuántos hay en cada celda
  (los cuenta al empezar y después de cada captura). Si falta uno: +40 de sospecha, "¿Dónde está el otro?" y se queda
  mirando 5 s más.
- El muñeco (`BunkDummy`): E en la almohada de la cucheta con las manos vacías y 3 s al lado arma el bulto; alejarse
  lo corta y E sobre uno armado lo deshace. Cuenta como un preso, pero si el guardia lo mira a menos de 2,5 m por 3 s
  es captura ("¡Esto es una almohada con una media!"). En una cuenta normal no llega a darse cuenta; si además falta
  alguien, sí.
- El peso: con un policía adentro la arrastra a la mitad de velocidad y se queja; dos bolsas pesadas seguidas suman
  +30. Una captura saca a todos de las bolsas y deshace los muñecos.
- Modelo `pillow_dummy`, 13 textos nuevos en es, en y pt. Pruebas en `test_garbage_bag.gd`.
