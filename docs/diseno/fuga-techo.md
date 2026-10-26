# La fuga: por el techo (propuesta, 25/10)

Octava variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.9: "con una cuerda hecha de sábanas").
Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y de las otras seis
([fuga-limpieza.md](fuga-limpieza.md), [fuga-perro.md](fuga-perro.md), [fuga-tunel.md](fuga-tunel.md),
[fuga-ventilacion.md](fuga-ventilacion.md), [fuga-basura.md](fuga-basura.md), [fuga-simulacro.md](fuga-simulacro.md),
decisiones 150 a 155): celdas con candado, una sola fuga por partida, salir en el patrullero, "¡Fugados!" y perder a la
tercera captura. Los números son **(propuesta)** hasta probarlos jugando.

## La idea
Es de noche. El guardia de noche está en su escritorio y la llave nunca sale de su cinturón. Pero cada celda tiene en
el techo una claraboya vieja, de cuando la comisaría era una panadería, y sobre las celdas está el depósito de arriba:
cajas de expedientes, sillas rotas y una escalera de mano hasta la trampa del techo. Arriba del todo, la antena.

El plan: subir por la claraboya, cruzar el depósito sin hacer ruido, salir al techo, atar las sábanas de las cuchetas en
una cuerda, atarla a la antena y bajar por la pared de atrás hasta el callejón. Desde ahí, al patrullero.

El chiste cooperativo: uno no llega a la claraboya solo, así que hay que "hacer pie". Y la cuerda es tan buena como sus
nudos: un nudo hecho a las apuradas aguanta a uno, pero no a dos colgados al mismo tiempo.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una, con las rejas cerradas. El guardia en su escritorio. En cada
   cucheta hay 2 sábanas (4 en total). Aviso: "Esa claraboya está floja... y nadie revisa el techo."
2. **Subir:** la claraboya está a 3 m. Desde la cucheta no se llega: hay que hacer pie (E sobre un compañero agachado
   lo sube a tus hombros, 1 s) o, jugando solo, apilar el colchón sobre la cucheta. Empujar la claraboya (E, 2 s) la
   abre con un crujido que el guardia puede oír.
3. **El depósito:** oscuro, con cajas que se caen si las chocas. Lo que se cae hace ruido abajo: el guardia mira el
   techo de las celdas y sube la sospecha. Si la sospecha pasa de 50, sube a mirar con la linterna.
4. **El techo:** la escalera de mano lleva a la trampa del techo. Arriba, correr hace ruido de pasos ("¿Ratas en el
   techo? ¿Ratas con zapatos?"). Caminar no.
5. **La cuerda:** las sábanas se atan una a otra (con una sábana en la mano, E sobre otra). E rápido hace un nudo flojo;
   mantener E 2 s, uno firme. La cuerda se ata a la antena (E). Con 4 sábanas llega al callejón; con menos, el último
   tramo es un salto que deja mareado (tambalea 3 s).
6. **Bajar:** E sobre la cuerda para agarrarse y bajar. Si dos bajan a la vez y hay un nudo flojo, se desata: los dos
   caen al callejón, mareados, y la cuerda queda más corta.
7. **Salir:** todos al patrullero, a 25 m del estacionamiento: "¡Fugados!".
8. **La captura:** a 100 de sospecha o si el guardia los ve fuera de la celda: todos a las celdas, la claraboya cerrada
   con un candado nuevo (hay que forzarla de nuevo, 4 s) y las sábanas de vuelta en las cuchetas. A la tercera llama
   al comisario: "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- Dónde están las cajas del depósito y cuáles están a punto de caerse.
- Qué claraboya está más floja (se abre en 1 s en vez de 2).
- Por qué lado del techo está la antena y, con eso, por qué pared se baja.
- Las frases: 10 o más del guardia oyendo ruidos arriba, con `tr()`.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento.
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66).

## Lo que se reusa
`JailbreakLevel` (celdas, capturas, salida, final, guardado y sorteo), `NightGuard` (la mirada, el oído y la sospecha),
lo que se cae y hace ruido (`heard_throw`), el ducto de la ventilación para moverse por arriba y el tambaleo de
`Cop.stagger`. Nuevo: la claraboya, hacer pie, el colchón, el depósito, la trampa y la antena, las sábanas y la cuerda.

## Online
Todo lo decide el anfitrión: la claraboya, los ruidos, la sospecha, los nudos y las capturas. Las sábanas y las cajas
van por `PropSync`; la claraboya, la cuerda y el guardia, por `NpcSync`; hacer pie y bajar por la cuerda, por las
acciones (`ActionSync`), igual en todas las PCs.

## Atajos del panel de pruebas (cuando exista)
- Empezar la fuga del techo (`--jailbreak=roof`).
- La cuerda ya hecha y atada.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo en octavos (`--jailbreak=roof`), las sábanas y el colchón, la claraboya, hacer pie y subir al depósito
   (modelos en `tools/modelgen`).
2. El depósito con sus cajas y el ruido, la escalera, la trampa y el techo con los pasos.
3. La cuerda de sábanas, los nudos, la antena, bajar al callejón, la captura y online.

## Preguntas para Cristian
1. ¿La fuga sortea en octavos entre las ocho variantes? **Recomiendo sí:** todas comparten celdas, salida y final.
2. ¿Se sube por una claraboya en el techo de cada celda, haciendo pie (o con el colchón, jugando solo)? **Recomiendo
   sí:** es la parte cooperativa y da risa, y jugando solo igual se puede.
3. ¿La cuerda son las 4 sábanas atadas, y un nudo flojo se desata con dos colgados a la vez? **Recomiendo sí:** obliga a
   hacer las cosas bien o a bajar de a uno, y el que se cae no pierde la partida.
