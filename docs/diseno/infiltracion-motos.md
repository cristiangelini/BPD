# Infiltración: Banda de motociclistas (variante 2 de infiltracion.md)

Décima variante de la infiltración, después del Club de abuelos, el Coro de iglesia, la Banda de mimos, la Fiesta de
disfraces, el Gimnasio, la Escuela de ladrones, el Restaurante y el Club de ajedrez (decisión 176, propuesta del
26/10). Se reusa casi todo: el lugar como `InfiltrationPlace`, la gente que mira con su medidor (`ClubMember` y
`ClubSuspicion`), el disfraz con las manos, 3 pruebas de 6 por la semilla, el caso con la planilla y el sueldo
(`InfiltrationCase.VARIANTS`), la huida con persecución si los descubren y el sorteo de "Jugar". Lo nuevo son **las
pruebas de valentía**: cada tanto un motoquero desafía a un policía a una prueba (una pulseada, levantar la moto o
quedarse quieto mientras le tiran la moto encima), y el que se achica levanta sospechas. Todo lo que dice
**(propuesta)** se ajusta jugando.

## La historia
La banda de motoqueros "Los Caños de Escape" se junta en el bar "El Caño Libre" y roba autopartes en toda la ciudad:
espejitos, autoestéreos y volantes, que vende en el taller del fondo. El jefe es El Cromado, un motoquero enorme que se
pasa el día lustrando su moto (que en realidad es un ciclomotor con manubrio alto). Los policías entran como
motoqueros nuevos, pasan las pruebas de valentía para que los respeten, juntan 3 pruebas y esposan a El Cromado.

El chiste: cuatro policías torpes que tienen que demostrar que son "duros" ante una banda que se toma la valentía muy
en serio, mientras los otros revisan el taller.

## Cómo es
1. **El lugar:** "El Caño Libre", un lote nuevo de la ciudad **(propuesta)**: el bar con la barra y mesas, el taller
   con motos y cajas, el patio de las pruebas (con la moto pesada y una raya pintada en el piso) y la oficina de El
   Cromado (con llave). Entre 8 y 10 motoqueros y el patovica de la puerta **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay, por policía, un pañuelo para la cabeza, una barba larga
   postiza (a la cara) y una campera de cuero con parches (al pecho). Con 2 de las 3 el policía pasa por motoquero
   (`is_disguised("biker")`). Con el uniforme, el patovica no lo deja pasar: "Acá no entran los de casco blanco."
   **(propuesta)**.
3. **Las pruebas de valentía (lo nuevo):** a los 20 s y después cada 50 s un motoquero elige a un policía que esté en
   el bar y le grita una prueba **(propuesta)**. El policía tiene 15 s para ir al lugar de la prueba (si no, "¡Gallina!"
   y +30 de sospecha de los motoqueros del bar). La semilla ordena los tres tipos:
   - **la pulseada:** en la mesa de las pulseadas, contra un motoquero. Hay que apretar E 15 veces en 8 s; si no
     llega, pierde y +20. Ganar o perder por poco no importa: lo que cuenta es no abandonar;
   - **levantar la moto:** la moto pesada del patio (50 kg, un objeto con física) hay que tenerla en el aire 5 s.
     Solo no se puede: tiene que llamar a otro policía (si los demás están ocupados, mala suerte). Si no la levanta en
     20 s, +20;
   - **no moverse:** el policía se para en la raya y un motoquero arranca la moto hacia él y frena a 1 m. Si se mueve
     más de 0,5 m de la raya antes de que frene, "¡Se movió!" y +20.
   Pasar la prueba hace que el motoquero se ponga contento y le cuente un chisme sobre una prueba que falta, como en
   el ajedrez **(propuesta)**. Mientras uno hace la prueba, todos los motoqueros miran el patio: es el mejor momento
   para que los otros revisen el taller y la oficina.
4. **La sospecha:** la del club con otros textos: sin disfraz, con una herramienta de policía en la mano, en la
   oficina, una pieza del disfraz que se cae y las pruebas que no pasan. A 100 un motoquero grita "¡Son policías!
   ¡Ningún motoquero pide permiso para pasar!".
5. **Las 3 pruebas** (la semilla elige 3 de 6) **(propuesta)**:
   - la caja de autoestéreos robados en el taller (se agarra, pesada);
   - el volante robado colgado como trofeo sobre la barra (se agarra);
   - foto del mapa de la ciudad con estacionamientos marcados, en la pared del taller;
   - el video de dos motoqueros hablando del "trabajo del jueves" (5 s cerca con la cámara, como el club);
   - la campera de El Cromado con un parche por cada robo, en el perchero del bar (E);
   - el cuaderno de ventas en el escritorio de la oficina (E; la llave está en el tanque de la moto de El Cromado, E en
     la moto).
6. **Se gana** esposando a El Cromado: sueldo de 600, un tercio menos por cada prueba que falte, cuota de 400, igual
   que las otras infiltraciones. Esposar a un motoquero los descubre. Detenido, el turno siguiente puede ser su
   interrogatorio (decisión 93): se le escapan 3 frases y confiesa.
7. **Si los descubren:** El Cromado sale a la calle en su "moto": un ciclomotor de 50 cc con manubrio de chopper, a
   30 km/h por la calle, haciendo "¡BRRRUM!" con la boca todo el camino **(propuesta)**.
8. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en el ajedrez y el restaurante: la semilla (los motoqueros, las pruebas y el orden de las
pruebas de valentía), a quién desafían, si llegó a tiempo, cuántas veces apretó E en la pulseada, si la moto está en
el aire y si el policía se movió de la raya, la sospecha de cada motoquero y las pruebas. La moto pesada es un objeto
con física que ya se sincroniza como los demás (`PropSync` / el agarre), y lo que dicen los motoqueros llega a todos.

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "biker"), `ClubMember` (motoqueros y El Cromado), `ClubSuspicion`
(con `prefix` "BIKER_"), `ClubDoorman` (el patovica), `ClubEvidence` y `ClubEvidenceSpot`, `KeyPot`, `DisguisePiece`
(tres piezas nuevas), `PlaceBuilder`, `ChaseCase` con un `SuspectCar` nuevo, `PlaceDraw` y `NpcSync`. Las pruebas de
valentía copian la forma de `ChessGames` (el host decide y avisa).

## El orden para hacerlo (un PR chico por paso)
1. El disfraz: pañuelo, barba y campera en el casillero, 2 de 3.
   Hecho así: 12 piezas en una fila del otro lado de la sala de guardia, al lado del café (las filas de los casilleros
   ya llegan a donde aparecen los policías): pañuelo rojo con lunares atado atrás (cabeza), barba larga gris postiza
   (cara, 1,17 m) y campera de cuero negra con cierre plateado y parches (pecho; doblada en el piso). Con 2 de las 3,
   `is_disguised("biker")` **(propuesta)**.
2. El bar en la ciudad (`--place=biker`): el bar, el taller, el patio, la oficina, los motoqueros, El Cromado y el
   patovica.
   Hecho así: un lote nuevo en la cuadra (6, 0), al sur, de 24 x 20 m, con el cartel naranja. El patovica (musculosa
   negra, pelado, anteojos oscuros y cadena) está en la entrada. Adelante, el bar (barra con botellas y 3 banquitos al
   oeste, 3 mesas y el perchero junto a la puerta) y, al este, el taller con piso de cemento, cajones, la pared de
   herramientas y el ciclomotor con manubrio de chopper de El Cromado, que lo lustra mirándolo. Atrás, el patio (vacío
   hasta el paso 3) y la oficina con llave detrás del taller. La semilla reparte 8 motoqueros (dos modelos: barba gris
   con pañuelo, y campera con cresta rosa) entre 11 lugares del bar, el taller y el patio **(propuesta)**.
3. Lo del patio: la mesa de las pulseadas, la moto pesada y la raya.
   Hecho así: la mesa alta de las pulseadas con dos almohadillas rojas (E es "hacer fuerza"; mientras alguien juega
   aparecen dos antebrazos agarrados, uno de manga azul y otro de cuero, que se inclinan hacia el que va ganando); la
   moto pesada, un chopper negro y cromado de 50 kg (un policía levanta 30 como mucho, dos levantan 60: hacen falta
   dos), que cuenta como "en el aire" 25 cm por encima de donde descansa; y el carril pintado del "no moverse", con un
   motoquero en una moto igual al fondo que arranca hacia la raya amarilla a 6 m/s, con ruido de motor, y frena a 1 m
   de ella **(propuesta)**.
4. Las pruebas de valentía: los desafíos, los tres tipos y la sospecha.
   Hecho así: a los 20 s y después cada 50 s, si hay un policía en el bar, un motoquero le grita la próxima prueba
   en el orden que dio la semilla ("¡Tú, el nuevo! ¡Pulseada en el patio!") y al policía le sale qué hacer. Tiene 15 s
   para llegar (a 1 m del lugar; para la moto, a 2,5 m); si no, "¡Gallina! ¡Cocoroco!" y +30 a los motoqueros del
   bar. Pulseada: 15 veces E en 8 s, los brazos se inclinan hacia el que va ganando; si no llega, "Brazo de fideo" y
   +20. Moto: 5 s seguidos en el aire dentro de 20 s; si no, +20. Raya: la moto arranca al empezar y, si el policía se
   aleja más de 0,5 m antes de que frene, "¡Saltó como un conejo!" y +20. Irse a más de 3 m en medio de la pulseada o
   la moto cuenta como no presentarse. Mientras dura, los motoqueros que no están en el patio miran la prueba y no ven
   nada más. Pasarla: "¡Eso es valentía! Respeto, hermano." (el chisme llega en el paso 5) **(propuesta)**.
5. Las pruebas y el caso (variante "biker"): las 6 pruebas, los chismes, el sueldo y el interrogatorio.
   Hecho así: la semilla elige 3 de estas 6 **(propuesta)**: la caja de cartón llena de autoestéreos entre los
   cajones del taller (12 kg, se agarra), el volante robado de marfil con un moño rojo sobre la barra (se agarra), el
   mapa de la ciudad con cuatro estacionamientos marcados en rojo en la pared del taller (foto), dos motoqueros que
   están cerca hablando del "trabajo del jueves" (video), la campera de El Cromado con parches de colores en el
   perchero (E) y el cuaderno azul de ventas en el escritorio de la oficina (E; la llave está en el tanque del
   ciclomotor de El Cromado, E en el tanque). El mapa y la campera están siempre, sean prueba o no. Pasar una prueba de
   valentía hace que el motoquero cuente un chisme de la primera prueba que falta ("¡Eso es valentía! Te cuento algo:
   ..."); si ya están todas, solo "Respeto, hermano". Esposar a El Cromado gana el caso (600 de sueldo, un tercio menos
   por prueba que falte), y en su interrogatorio se le escapan 3 frases y confiesa lo de los autoestéreos. Hasta el
   paso 6 escapa a pie.
6. La huida en el ciclomotor, el sorteo de "Jugar" en novenos y online.
   Hecho así: descubiertos, El Cromado sale del taller en su ciclomotor con manubrio de chopper a 30 km/h por la
   calle (se lo persigue en patrullero), con el ruidito del motor y un "¡BRRRUM!" grande sobre la cabeza todo el
   camino, que se apaga cuando lo atrapan. "Jugar" sortea las infiltraciones en novenos. Online, el host decide las
   pruebas de valentía y les avisa a los demás lo que gritan los motoqueros, los brazos de la pulseada (y cuánto se
   inclinan) y la moto que arranca hacia la raya; la moto pesada es un objeto con física como los demás
   **(propuesta)**.

## Preguntas para Cristian (decisión 176)
1. **¿Hay pruebas de valentía de verdad cada 50 s (pulseada apretando E, levantar la moto entre dos y quedarse quieto
   en la raya) y el que no se presenta o no la pasa levanta sospechas?** Recomiendo que sí: es lo que dice el caso
   ("hay que hacer pruebas de valentía"), y las tres usan lo que ya hay (E, la física y moverse).
2. **¿Los policías se disfrazan de motoquero (pañuelo, barba larga y campera de cuero, 2 de 3)?** Recomiendo que sí,
   para mantener la regla del disfraz.
3. **¿El Cromado escapa en un ciclomotor con manubrio de chopper a 30 km/h haciendo "¡BRRRUM!" con la boca?**
   Recomiendo que sí: es lento y ridículo para alguien que se hace el duro.

Mientras no respondas, se avanza con lo recomendado.
