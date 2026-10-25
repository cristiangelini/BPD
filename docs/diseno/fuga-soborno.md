# La fuga: sobornar al guardia (propuesta, 25/10)

Novena variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.6: "con la plata de las coimas, si les
queda"). Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y de las otras siete
([fuga-limpieza.md](fuga-limpieza.md), [fuga-perro.md](fuga-perro.md), [fuga-tunel.md](fuga-tunel.md),
[fuga-ventilacion.md](fuga-ventilacion.md), [fuga-basura.md](fuga-basura.md), [fuga-simulacro.md](fuga-simulacro.md),
[fuga-techo.md](fuga-techo.md), decisiones 150 a 156): celdas con candado, una sola fuga por partida, salir en el
patrullero, "¡Fugados!" y perder a la tercera captura. Y la plata de las coimas de [sobornos.md](sobornos.md)
(decisiones 30 y 190 a 192). Los números son **(propuesta)** hasta probarlos jugando.

## La idea
Es de noche. El guardia de noche está despierto en su escritorio, con la llave en el cinturón, y tiene cara de que se
vende. Los policías aceptaron coimas durante la partida: esa plata la tienen escondida en las medias. El plan es
devolverle el favor a la corrupción: juntar la plata de los cuatro, pagarle al guardia y salir caminando.

Dos problemas. Uno: la cámara del pasillo, que gira de una celda a la otra; con la cámara mirando, el guardia no agarra
nada ("¿Con la cámara? ¿Estás loco?"). Dos: el guardia es corrupto pero no tonto. Pagado, "se le cae" la llave y se da
vuelta a leer el diario un rato. Cuando termina la página, vuelve a mirar, y si ve a alguien afuera, lo agarra igual.
La plata no se devuelve.

El chiste cooperativo: nadie tiene toda la plata. Cada uno tiene su fajo, y hay que pasárselo al guardia de a uno
mientras otro vigila la cámara y grita "¡AHORA!".

## De dónde sale la plata
- La campaña guarda cuánto juntaron en coimas (lo que aceptaron menos las multas del agente). Eso es lo que tienen en
  las medias, pero nunca más que la caja del grupo: "si les queda".
- Al despertar, la plata se reparte entre los 4 en fajos de billetes (agarrables), uno debajo de cada colchón.
- Lo que le paguen al guardia se descuenta de la caja del grupo al terminar la fuga, se escapen o no.
- Solo entra en el sorteo si les quedan al menos 200 (el precio más bajo del guardia). Si no, la fuga sortea entre las
  otras ocho, como hasta ahora.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una. El guardia en su escritorio. Debajo de cada colchón, un fajo.
   Aviso: "El guardia tiene cara de que se vende... pero la cámara mira todo."
2. **Llamarlo:** E en las rejas: "¡Psst, guardia!". Viene hasta la reja y dice su precio: entre 200 y 500 según la
   semilla, nunca más de lo que tienen ("Por menos de 300 ni me levanto").
3. **La cámara:** está en el techo del pasillo y gira despacio de una celda a la otra (8 s de cada lado). Tiene una
   lucecita roja que muestra para dónde mira.
4. **Pagar:** con un fajo en la mano, E sobre el guardia se lo pasa por la reja. Lo cuenta (2 s) y lo guarda. Si la
   cámara mira esa celda mientras cuenta, devuelve el fajo y sube la sospecha. Lo que va pagando se suma: cuatro fajos
   chicos valen lo mismo que uno grande.
5. **Regatear:** con E sostenido en las rejas ("Dale, que somos colegas"), el precio baja 50, hasta 3 veces. Cada vez
   suma 15 de sospecha: al guardia no le gusta que lo apuren.
6. **Pagado:** "Uy, se me cayó la llave. Qué torpe." La llave queda en el piso del pasillo, al alcance de una reja, y
   el guardia vuelve al escritorio y se da vuelta a leer el diario: 30 s sin mirar.
7. **Salir:** abrir las celdas, cruzar la comisaría y llegar al patrullero, a 25 m del estacionamiento: "¡Fugados!".
   El diario no tapa el oído: correr, tirar cosas o tocar bocina igual suben la sospecha.
8. **Cuando vuelve a mirar:** el que siga adentro de la comisaría y fuera de la celda, a su vista, es una captura.
9. **La captura:** a 100 de sospecha o si el guardia los ve afuera mirando: todos a las celdas y la llave de vuelta al
   cinturón. Lo pagado, pagado ("La plata no se devuelve, eso es de la casa"): cuenta para el próximo intento, pero el
   precio sube 100. A la tercera llama al comisario: "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- El precio del guardia (200 a 500, de a 50) y cómo se reparte la plata entre los fajos.
- Para qué lado arranca la cámara y cuánto tarda en girar (6 a 10 s de cada lado).
- Cuánto le dura la página del diario (25 a 35 s).
- Las frases: 10 o más del guardia pidiendo, contando, regateando y "perdiendo" la llave, con `tr()`.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento.
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66). La plata sí se acaba: si no les alcanza ni regateando, solo les queda salir
  antes de que termine la página. Si no tienen nada más para pagar, el guardia igual se duerme a los 3 minutos (como en
  la dona) y la llave queda en el cinturón: se puede seguir como la fuga de la dona.

## Lo que se reusa
`JailbreakLevel` (celdas, capturas, salida, final, guardado y sorteo), `NightGuard` (la mirada, el oído y la
sospecha), la llave que cae de la dona, las cuentas de las coimas en `Campaign` y `Bribes`. Nuevo: los fajos, la cámara
del pasillo, el guardia que cobra, regatea y lee el diario, y la plata guardada de las coimas.

## Online
Todo lo decide el anfitrión: lo pagado, el precio, la cámara, la sospecha, el diario y las capturas. Los fajos van por
`PropSync`; la cámara y el guardia, por `NpcSync`; llamar, pagar y regatear, por las acciones (`ActionSync`), igual en
todas las PCs.

## Atajos del panel de pruebas (cuando exista)
- Empezar la fuga del soborno (`--jailbreak=bribe`, con 400 en las medias si la partida no tiene).
- El guardia ya pagado.

## El orden para hacerlo (un PR chico por paso)
1. La plata guardada de las coimas, el sorteo en novenos cuando alcanza (`--jailbreak=bribe`), los fajos, llamar al
   guardia, el precio, pagar de a fajos, la llave en el piso y descontar de la caja (modelos en `tools/modelgen`).
2. La cámara del pasillo que gira, pagar a su vista, regatear y la sospecha.
3. El diario de 30 s, volver a mirar, la captura con lo pagado y el precio que sube, la salida y online.

## Preguntas para Cristian
1. ¿La fuga del soborno solo sale si les quedan al menos 200 de las coimas (y lo que pagan sale de la caja)? **Recomiendo
   sí:** es "si les queda" del catálogo, y la corrupción tiene precio.
2. ¿Se paga juntando los fajos de los cuatro, de a uno por la reja, con la cámara del pasillo que gira y no deja pagar
   a su vista? **Recomiendo sí:** obliga a coordinarse y a gritar "¡ahora!".
3. ¿Pagado, el guardia "pierde" la llave y lee el diario 30 s, y el que siga afuera cuando vuelve a mirar es captura,
   sin devolver la plata (cuenta para el próximo intento, pero el precio sube 100)? **Recomiendo sí:** es corrupto pero
   no tonto, y hay que salir rápido pero sin correr.

## Cómo quedó el paso 1
- La campaña guarda la plata de las coimas (`Campaign.bribe_money`): suma cada coima aceptada y resta las multas del
  agente. Lo que hay para el guardia es eso, pero nunca más que la caja del grupo (`bribe_fund`).
- El sorteo es en novenos solo si quedan al menos 200; si no, sigue en octavos entre las otras.
  `--jailbreak=bribe` la fuerza y, si la partida no tiene 200, pone 400.
- La plata está repartida en 4 fajos (`BillWad`), de a 50, sobre las cuchetas (no debajo del colchón: así se ven).
- El guardia (`BribeGuard`): E en la reja cerrada lo llama ("¡Psst, guardia!"). Viene caminando por el costado del
  escritorio hasta esa reja y dice su precio. Con un fajo en la mano, E en la reja se lo pasa: lo cuenta 2 s, se lo
  queda y dice cuánto falta. Si en 15 s no le pasan nada, vuelve al escritorio.
- Pagado entero, dice que se le cayó la llave y la patea por debajo de la reja, adentro de la celda. Después vuelve al
  escritorio y lee el diario de espaldas a las celdas (por ahora sin fin: la página de 30 s es el paso 3).
- Lo que cobró sale de la caja del grupo y de la plata de las coimas cuando termina la fuga.
- Modelo `bill_wad` en `tools/modelgen/models/bribe.js`. 15 textos nuevos. Pruebas en `test_bribe_money.gd`. Fotos en
  `/mnt/project-files/soborno/`.

## Cómo quedó el paso 2
- La cámara del pasillo (`CorridorCamera`) cuelga del techo frente a las celdas y gira de una reja a la otra: se queda
  entre 6 y 10 s en cada una (según la semilla, que también elige por cuál arranca) y tarda 1,5 s en girar, sin mirar a
  ninguna mientras gira. Una luz roja ilumina el piso de la reja que mira.
- El guardia cuenta el fajo en la mano. Si mientras cuenta la cámara mira esa celda, devuelve el fajo adentro de la
  celda, dice una de 3 frases ("¿Con la cámara mirando? ¿Estás loco?") y suma 10 de sospecha.
- Con las manos vacías frente al guardia en la reja, E regatea ("Dale, que somos colegas"): el precio baja 50, hasta 3
  veces, y cada vez suma 15 de sospecha. Si el precio llega a lo que ya cobró, es trato hecho.
- Online: la cámara va por `NpcSync` y lo regateado viaja con el guardia.
- Modelo `corridor_camera`. 7 textos nuevos. Pruebas en `test_bribe_camera.gd`. Fotos en `/mnt/project-files/soborno/`.
