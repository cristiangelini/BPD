# La fuga (cuando los detienen a ellos)

Tipo de caso 7 del catálogo ([casos.md](casos.md)). Junta las decisiones 15, 17, 66, 88 y 99. Todo lo que no salió de
Cristian está marcado **(propuesta)** hasta probarlo jugando.

## Qué es
Hoy, si un turno no llega a la cuota, sale "Suspendidos" y termina la partida (decisión 88). Con la fuga, esa pantalla
pasa a ser el principio de otra cosa: los 4 aparecen de noche, presos en las celdas de su propia comisaría, y tienen
que escaparse (decisión 17). Si se escapan, la partida sigue; si no, ahí sí termina.

## Cuándo pasa
- Al estacionar con un turno que no llegó a la cuota, la pantalla del turno dice "Suspendidos" y, en vez de volver al
  menú, se apaga la luz y aparecen en las celdas.
- **Una sola fuga por partida (propuesta).** Si vuelven a no llegar a la cuota después de haberse escapado, el
  comisario cambia la cerradura y termina la partida con "Suspendidos", como hoy.
- **Si se escapan, siguen con el turno siguiente (propuesta):** a la mañana el comisario no se dio cuenta de nada
  ("¿Durmieron acá? Qué compromiso."). El turno fallado no suma plata a la caja y la cuota del turno siguiente es la de
  siempre (sube 100). Así la fuga es una segunda oportunidad, no un premio.
- La fuga no tiene sueldo ni cuota propia: no es un turno, es lo que pasa entre dos turnos.

## La primera variante: la llave en la dona (3 del catálogo)
El guardia de noche (un NPC pera, con gorra y termo) está sentado en el escritorio de la sala de guardia, frente a las
celdas, con una caja de 6 donas. Esa tarde se le cayó la llave de las celdas adentro de una dona y no se dio cuenta.

- **Las celdas:** son las 2 que ya están en la comisaría, con 2 policías en cada una **(propuesta)**. La reja tiene
  cerradura y no se abre con E ni con el ariete. En cada celda hay una cucheta, una frazada y algo largo y absurdo
  para pescar: en una un palo de escoba, en la otra una caña de pescar sin anzuelo **(propuesta)**.
- **El guardia come:** cada 40 s **(propuesta)** saca una dona de la caja y se la come. La semilla sortea cuál tiene la
  llave. Si se come la de la llave, la escupe ("¿Qué es esto? ¡Mi llave!"), se la cuelga del cinturón y desde ahí hay
  que sacársela mientras duerme (abajo). No se pierde el caso, solo se pone más difícil.
- **Pescar la caja:** el escritorio queda a 3 m de la reja **(propuesta)**. Con el palo o la caña (agarrar y tirar con
  las manos, como los muebles) se arrastra la caja hasta la reja. Cada dona se parte agarrándola con las dos manos;
  la que tiene la llave la suelta al partirse. Las otras se pueden comer (resistencia llena, como las de la armería).
- **La llave:** con la llave en la mano, E sobre la cerradura abre esa celda. La otra celda se abre con la misma llave
  desde afuera.
- **El guardia mira:** gira la cabeza de a ratos y ve en un cono de 70° y 10 m **(propuesta)**. Si ve a alguien fuera
  de la celda, la caja moviéndose o una dona rota, sube su sospecha (barra arriba, de 0 a 100). Si llega a 100, se
  levanta, agarra al que está afuera, lo vuelve a meter, cierra la celda, recupera la caja y le quita el palo o la
  caña. La sospecha vuelve a 0.
- **Distraerlo:** tirar algo lejos de él (la frazada, una dona, una almohada) lo hace ir a mirar 4 s **(propuesta)**.
  Hablar fuerte por la voz de proximidad ([voz.md](voz.md)) lo hace girar hacia la voz. Cantar le da sueño: si los 4
  cantan juntos, se duerme 15 s **(propuesta)**, y dormido no mira ni sospecha (y se le puede sacar la llave del
  cinturón).
- **Salir:** desde las celdas, por la sala de guardia y la puerta de la calle, hasta el patrullero del
  estacionamiento. Se escapan cuando los 4 están en el patrullero y sale del estacionamiento.

**Cómo quedó el paso 1:** la partida guarda si están presos y si ya usaron la fuga. La primera cuota fallada no suma
plata y, en la pantalla del turno, abajo de "Suspendidos" dice "…y esta noche duermen en sus propias celdas. ¡A
escaparse!", con el botón para seguir. El turno siguiente es la fuga: la comisaría de noche (luna, luces bajas y
cálidas, sin el comisario ni el armero) con los 4 en las celdas, dos en cada una, mirando la reja. Cada celda tiene
ahora una puerta de reja de 1,2 m con candado: cerrada con llave, E solo la sacude. Si fallan la cuota del turno 5, la
fuga va antes del final y no salen "¡Ascendidos!" desde la celda **(propuesta)**. Capturas: `fuga/paso1_celda.png` y
`paso1_celdas.png`.

**Cómo quedó el paso 2:** el guardia de noche (el modelo del carcelero) está sentado detrás de un escritorio en la
sala de las celdas, entre las dos puertas, mirando las rejas. Sobre el escritorio, a 2,75 m de las rejas, está su caja
de 6 donas (un modelo nuevo, `guard_donut_box`). Cada 40 s se come la última que queda y dice algo ("Una más y mañana
empiezo la dieta."). Si es la de la llave, la escupe: "¿Qué es esto? ¡Mi llave! Mejor me la cuelgo del cinturón.". Si
la caja no está a 1,5 m de él, se queja: "¿Y mis donas? ¿Quién se llevó mis donas?" **(propuesta)**. Online, el host
come y los invitados ven la misma caja. Captura: `fuga/paso2_guardia.png`.

**Cómo quedó el paso 3a (pescar la caja):**
- En el piso de cada celda hay algo largo: en una, un escobillón de 2,8 m; en la otra, una caña de pescar de 3 m sin
  anzuelo. Los dos son modelos nuevos.
- Se agarran como cualquier cosa. En la mano apuntan adonde mira el policía (un poco abajo y a la derecha, para que se
  vean) y pasan entre las rejas.
- Con la punta a menos de 0,6 m de la caja de donas, E la engancha. La caja sigue a la punta: caminando hacia atrás se
  la arrastra hasta la reja, pero no pasa entre las rejas.
- E la suelta. Si se traba a más de 1 m de la punta, se suelta sola ("¡Se soltó la caja!"). Soltar el palo también la
  suelta.
- Lejos de su escritorio, el guardia ya no la alcanza y pregunta por sus donas **(propuesta)**.
- Capturas: `fuga/paso3_escoba.png` (desde la celda) y `paso3_escoba_afuera.png` (desde afuera).

## Cómo se gana y cómo se pierde
- **Se gana** con los 4 en el patrullero fuera del estacionamiento. Pantalla corta "¡Fugados!" y a la mañana arranca el
  turno siguiente en la comisaría.
- **Se pierde** si el guardia los atrapa 3 veces **(propuesta)**: llama al comisario, que llega en pijama y grita, y
  termina la partida con "Suspendidos".
- **Sin tiempo límite** (decisión 66): la presión es la sospecha del guardia y las donas que se va comiendo.

## Las otras variantes (más adelante, al azar con la semilla)
Las 10 del catálogo: por la ventilación, disfrazados de limpieza, la llave en la dona, túnel con cucharas, el camión
de la basura, sobornar al guardia, simulacro de incendio, el perro guardián, por el techo con sábanas y el juicio
rápido. Las de la comisaría reusan las mismas celdas y el mismo guardia; cada una cambia la forma de salir.

## Online
Todo lo decide el host, como el resto de los casos: la semilla, cuál dona tiene la llave, la sospecha, las veces que
los atrapa y si se escaparon. La fuga se guarda como un estado más de la partida (`Campaign`), así que si se corta en
medio, al volver se aparece de nuevo en las celdas.

## Atajos del panel de pruebas
- Empezar la fuga (turno fallado).
- Mostrar cuál dona tiene la llave.
- Dormir al guardia.

## El orden para hacerlo (un PR chico por paso)
1. La partida guarda la fuga: no llegar a la cuota la primera vez lleva a las celdas de noche (comisaría a oscuras,
   las rejas con cerradura y los 4 adentro); la segunda vez termina como hoy.
2. El guardia de noche en su escritorio con la caja de donas, comiéndose una cada 40 s.
3. El palo y la caña, pescar la caja, partir las donas, la llave y abrir las celdas.
4. La mirada y la sospecha del guardia, y que los vuelva a meter.
5. Distraerlo: tirar cosas, la voz y cantar para dormirlo (y sacarle la llave del cinturón).
6. Salir en el patrullero, "¡Fugados!", el turno siguiente, y perder a la tercera.

## Preguntas para Cristian (respondidas el 22/10: sí a las tres, decisión 99)
1. ¿Una sola fuga por partida? La segunda vez que no llegan a la cuota termina como hoy.
2. ¿Si se escapan siguen con el turno siguiente, sin la plata del turno fallado?
3. ¿Perder si el guardia los atrapa 3 veces?
