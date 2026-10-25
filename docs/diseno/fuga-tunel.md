# La fuga: el túnel con cucharas (propuesta, 25/10)

Cuarta variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.4: "cavan mientras los otros tapan el
ruido"). Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y de las otras dos
([fuga-limpieza.md](fuga-limpieza.md), decisión 150; [fuga-perro.md](fuga-perro.md), decisión 151): celdas con
candado, una sola fuga por partida, salir en el patrullero, "¡Fugados!" y perder a la tercera captura. Los números son
**(propuesta)** hasta probarlos jugando.

## La idea
Es de noche y el guardia está despierto en su escritorio, sin donas y aburrido: lo único que hace es escuchar. En
cada celda hay una bandeja de la cena con dos cucharas. Debajo de la cucheta el piso está flojo: con paciencia y una
cuchara se puede cavar un túnel hasta el estacionamiento. El problema es que cavar hace ruido ("scrich, scrich") y el
guardia tiene buen oído.

El chiste cooperativo: en cada celda uno cava y el otro canta, silba o hace ruido para tapar el raspado. Si cantan los
cuatro a la vez el guardia se duerme (como en la dona), pero entonces nadie cava.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una, con las rejas cerradas. El guardia en su escritorio con la
   llave en el cinturón. Aviso: "El piso debajo de la cucheta está flojo... y en la bandeja hay cucharas."
2. **Las cucharas:** dos en la bandeja de cada celda. Se agarran con la mano como cualquier cosa.
3. **Cavar:** con una cuchara en la mano, E sobre el pozo (al lado de la cucheta) saca una cucharada (como mucho una
   cada 0,6 s). Cada túnel necesita 80 cucharadas. Con las cucharadas el pozo se ve más hondo y sale tierra al piso.
   Cada celda cava su propio túnel.
4. **El ruido:** cada cucharada hace ruido. Si en ese momento nadie de esa celda está tapando el ruido, al guardia le
   sube la sospecha 12. Tapan el ruido: cantar o la H (la misma tecla de cantar al guardia), a menos de 3 m del pozo.
   Si cantan los cuatro a la vez 3 s, el guardia se duerme 15 s, como en la dona.
5. **El guardia escucha:** sin ruidos raros la sospecha baja 8 por segundo. Con 60 o más se levanta y va a mirar la
   celda del ruido ("¿Qué es ese ruido?"). Se queda 4 s frente a la reja: si ve el pozo destapado o a alguien con una
   cuchara en el pozo, los atrapa; si no, vuelve ("Será una rata.") y la sospecha baja a 30.
6. **Tapar el pozo:** el colchón de la cucheta se saca con las manos y se pone encima del pozo. Tapado, el guardia no
   lo ve. Hay que destaparlo para seguir cavando.
7. **La captura:** a 100 de sospecha, o si ve el pozo, se enoja: "¡Un túnel! ¡Con cucharas! ¿Son ratones?". Se lleva
   las cucharas que vea, el pozo de esa celda pierde un tercio de lo cavado y los que estaban afuera vuelven a una
   celda. Las capturas cuentan igual: "Capturas del guardia: 1 de 3".
8. **El túnel terminado:** con las 80 cucharadas el pozo se abre. Un policía que se mete (E) aparece atrás de la
   comisaría, al lado del estacionamiento. Los del túnel ya no vuelven a la celda (salvo que los atrapen afuera).
9. **Salir:** todos en el patrullero, a 25 m del estacionamiento: "¡Fugados!". El guardia ve el estacionamiento por la
   ventana: si ve a alguien afuera, también suma sospecha.
10. **Perder:** a la tercera captura el guardia llama al comisario, que llega en pijama: "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- Dónde está el pozo de cada celda (a la izquierda o a la derecha de la cucheta).
- Cuántas cucharadas hacen falta en cada celda (70 a 90).
- Las frases: 10 o más del guardia escuchando, mirando y atrapando, con `tr()` en es, en y pt.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento. Sigue el turno siguiente sin la plata
  del turno fallado (decisión 99).
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66): la presión es el oído del guardia.

## Lo que se reusa
`JailbreakLevel` (celdas, capturas, salida, final, guardado y el sorteo de variantes), `NightGuard` (la mirada, la
sospecha, dormirse con el canto), el canto de `VoiceChat`, `Grabbable` para las cucharas y el colchón, y la manera de
caminar del comisario madrugador para que el guardia vaya a mirar. Nuevo: el pozo y el túnel, las cucharas, el
colchón y el guardia que escucha.

## Online
Todo lo decide el anfitrión: cuánto cavó cada celda, el ruido, la sospecha, el guardia que va a mirar y las capturas.
El guardia y los pozos van por `NpcSync`; las cucharas y los colchones, por `PropSync`.

## Atajos del panel de pruebas (cuando exista)
- Empezar la fuga del túnel (`--jailbreak=tunnel`).
- Terminar el túnel de una celda ya.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo en cuartos (`--jailbreak=tunnel`), el guardia despierto sin donas, las cucharas, el pozo de cada celda y
   cavar con E (modelos en `tools/modelgen`).
2. El ruido: tapar cantando, el guardia que escucha, va a mirar y atrapa, y la captura que rellena un tercio.
3. El colchón que tapa el pozo, el túnel terminado que saca al estacionamiento, salir, frases y online.

## Cómo quedó el paso 1
- `--jailbreak=tunnel` fuerza la variante; el sorteo de la fuga ahora es en cuartos (dona, limpieza, perro, túnel).
- `ListeningGuard` (scripts/npc/listening_guard.gd): despierto, sin donas, con la llave en el cinturón.
- Dos bandejas con dos cucharas cada una (`Spoon`), y un `TunnelHole` por celda, del lado que sortea la semilla.
- E con una cuchara en la mano saca una cucharada cada 0,6 s; el pozo necesita entre 70 y 90 (la semilla elige)
  y se ve crecer junto con la montaña de tierra. Sin cuchara dice que hace falta una.
- Modelos `tunnel_spoon` y `tunnel_mattress` en `tools/modelgen/models/tunnel.js`. Pruebas en `test_spoon_tunnel.gd`.

## Preguntas para Cristian
1. ¿La fuga sortea en cuartos entre dona, limpieza, perro y túnel? **Recomiendo sí:** las cuatro comparten celdas,
   salida y final.
2. ¿Que cantar (o la H) tape el ruido de cavar, aunque si cantan los cuatro el guardia se duerme como en la dona?
   **Recomiendo sí:** obliga a repartirse, uno cava y otro canta, y dormirlo no ayuda porque nadie cava.
3. ¿Que una captura rellene un tercio del pozo en vez de todo? **Recomiendo sí:** perderlo todo con 80 cucharadas es
   demasiado castigo.
