# BPD · Control de tránsito: Mudanza del circo (propuesta, 25/10)

Novena variante del control de tránsito ([control-transito.md](control-transito.md), variante 6;
[casos.md](casos.md), punto 8.6). Reusa el control de "Hora pico" y lo de las otras variantes
([control-payasos.md](control-payasos.md), [control-frutas.md](control-frutas.md),
[control-auto-lleno.md](control-auto-lleno.md), [control-auto-fantasma.md](control-auto-fantasma.md),
[control-boda.md](control-boda.md), [control-carrera.md](control-carrera.md), [control-neblina.md](control-neblina.md)):
conos, barrera, la fila y su medidor, papeles, baúl, denuncias, escolta, el sorteo por semilla y la persecución. La
foca y los modelos del circo son los de la escena del crimen ([escena-circo.md](escena-circo.md)). Los números son
**(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! Anoche robaron la joyería del centro y el ladrón, El Peludo, se disfrazó de animal. Justo
hoy se muda el circo y sus camiones con jaulas salen de la ciudad por la avenida: seguro que se metió en una jaula.
Revisen los animales. Y por favor, no me suelten ningún león."

## Cómo es
1. **La caravana del circo:** por el control pasan 10 a 14 **camiones del circo** (a rayas, cada uno con una jaula
   atrás) mezclados con 4 a 6 autos comunes. En cada jaula hay un animal: **león, oso, gorila, mono, foca, cebra o
   canguro**. Los papeles del camión dicen qué animal lleva.
2. **Darles de comer:** en el baúl del patrullero hay 4 baldes (se agarran como la linterna): **bananas** (gorila y
   mono), **pescado** (foca y oso), **carne** (león) y **zanahorias** (cebra y canguro). Con E en la jaula se le da
   al animal lo del balde:
   - Si es su comida, **come contento** (globito "¡Ñam!").
   - Si no, **se enoja**: ruge y sacude la jaula (el camión tiembla, la fila se impacienta un poco).
   - **El Peludo no come nada**: con su comida dice algo de persona ("No, gracias, ¿no tenés un sándwich?", 10+
     frases con tr()). Es la prueba fuerte, pero hay que saber qué come cada animal.
3. **Cuando nadie lo mira:** si ningún policía mira la jaula de El Peludo durante 5 s, hace **cosas de persona**:
   mira el reloj, lee el diario, se rasca la cabeza con la pata, se saca la cabeza del disfraz para secarse
   (globito y animación de 2 s, 10+ con tr()). Si un policía se da vuelta justo, lo ve.
4. **Abrir la jaula:** con E en la puerta. El Peludo se queda quieto y se lo puede esposar. Un **animal de verdad
   se escapa** y corre por la fila: hay que **meterlo de vuelta** mostrándole su comida (te sigue hasta la jaula).
   Si en 40 s no volvió, se va de la ciudad y es **denuncia** del circo.
5. **Las pistas:** la radio da una pista cada 60 s: **qué animal parece** (oso, gorila, león o
   canguro, los disfraces en los que entra una persona), el **color de las zapatillas** que asoman de las patas, el
   **color del camión** (las rayas) y el **número de la jaula**. Hay 2 o 3 animales de verdad que se le parecen.
6. **Se gana** deteniendo a El Peludo y llevándolo al patrullero: 500, misma cuota que Hora pico. Las **joyas**
   están escondidas en la paja de su jaula: en el baúl del patrullero suman 100. Detener a un inocente (el chofer de
   un camión) es denuncia y a la segunda se pierde, como siempre.
7. **Se pierde** si el camión de El Peludo pasa el control: se escapa por la ciudad (persecución) y **en cada
   esquina tira cáscaras de banana** que hacen patinar al patrullero. Si se escapa también ahí, se pierde el caso.
8. En "Jugar", el control de tránsito sale un noveno cada variante: Hora pico, Caravana, Camión de frutas, Auto
   lleno, Auto fantasma, Boda, Carrera, Neblina y Mudanza del circo.

## Lo nuevo
- Los camiones del circo con su jaula y los animales (variante `circus_move`).
- Los baldes de comida y lo que hace cada animal con cada comida.
- Las cosas de persona de El Peludo cuando nadie lo mira.
- Abrir la jaula, el animal suelto y meterlo de vuelta con su comida.
- El plan: El Peludo, sus pistas (animal, zapatillas, camión, jaula) y los parecidos (sobre WantedPlan).
- Las joyas como prueba (+100 en el baúl).
- La persecución con cáscaras de banana en las esquinas.

## Preguntas para Cristian
1. **¿El sospechoso es una persona disfrazada de animal (El Peludo), que se delata porque no come y porque hace
   cosas de persona cuando nadie lo mira?**
   Recomiendo que sí: obliga a repartirse, uno que mira y otro que se da vuelta, y es gracioso de ver.
2. **¿Abrir la jaula de un animal de verdad lo suelta por la fila, y hay que meterlo de vuelta con su comida (si no,
   denuncia)?**
   Recomiendo que sí: castiga abrir todas las jaulas al azar y arma lío en la fila.
3. **¿Si se escapa, tira cáscaras de banana en las esquinas que hacen patinar al patrullero?**
   Recomiendo que sí: es lo propio de esta persecución, como los trompos de la carrera.

## El orden para hacerlo (un PR chico por paso, apilados sobre la Neblina)
1. Los camiones del circo, las jaulas y los animales (variante `circus_move`).
2. Los baldes de comida y lo que hace cada animal.
3. Las cosas de persona cuando nadie mira; abrir la jaula, el animal suelto y meterlo de vuelta.
4. El plan: El Peludo, sus pistas, la radio y los parecidos.
5. Detener, escoltar, las joyas +100, sueldo, el escape con cáscaras de banana y el sorteo en "Jugar".
6. Online.

## Online
Como las otras variantes: el anfitrión decide la fila, quién es El Peludo, qué hace cada animal con la comida y
cuándo hace cosas de persona; los baldes son objetos que se agarran (PropSync), el animal suelto es un NPC del
anfitrión (NpcSync), y cada PC ve los mismos globitos y el final ([online.md](online.md)).
