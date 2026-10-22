# Infiltración: Coro de iglesia (variante 8 de infiltracion.md)

Segunda variante de la infiltración (decisión 100). Se reusa casi todo lo del Club de abuelos: el disfraz con las
manos, la sospecha de muchos (cada corista con su medidor), las pruebas (3 de 6 por la semilla), el caso con la
planilla y el sueldo, la persecución embebida si los descubren y el sorteo de "Jugar". Lo nuevo es cantar. Cristian respondió
las 3 preguntas el 22/10 (decisión 101); lo que sigue diciendo **(propuesta)** se ajusta jugando.

## La historia
La capilla del barrio junta plata "para el órgano nuevo" desde hace diez años y el órgano nunca llega. El comisario
cree que el director del coro, el **Maestro Ernesto**, se queda con las colectas. Los policías
entran como coristas nuevos al ensayo del sábado, cantan con los demás sin desafinar demasiado, juntan 3 pruebas y lo
esposan. No hay nada religioso en las pruebas ni en los chistes: el chiste es el coro y el director tramposo.

## Cómo es
1. **El lugar:** "Capilla del barrio", un lote nuevo en la ciudad (como el club): la nave con bancos, el coro en una
   tarima con atriles, el órgano de cartón pintado, la sacristía (con llave) y un depósito. Entre 12 y 16 coristas
   **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay túnicas de coro y cancioneros. Se pone la túnica llevándola al
   pecho con las manos (como la peluca) y el cancionero se lleva en la mano. Sin túnica, el portero (aquí, la señora de
   la puerta) no deja pasar **(propuesta)**.
3. **Cantar (lo nuevo):** el Maestro Ernesto marca con la batuta. Cuando la levanta, todo el coro canta; cuando la
   baja, silencio. Cada policía en la tarima canta con la voz (el micrófono, con el SongMeter de la fuga) o
   manteniendo H si no tiene micrófono. Lo que da sospecha: no cantar con la batuta arriba, cantar con la batuta abajo
   (el solo que nadie pidió) y bajarse de la tarima durante un canto. **Afinado:** que el juego distinga notas por el
   micrófono es caro y falla mucho: se mide solo el tiempo (cantar cuando hay que cantar) y no la nota (decisión
   101).
4. **La sospecha:** como en el club, cada corista ve un cono adelante. Además de correr, las herramientas a la vista
   y entrar a la sacristía, suma cantar fuera de tiempo y la túnica que se cae.
5. **Las 3 pruebas** (la semilla elige 3 de 6): la alcancía de la colecta con doble fondo (agarrarla), el cuaderno del
   director con "órgano: 0" (en la sacristía), el órgano de cartón (sacarle una foto de atrás), los recibos del
   "fondo del órgano" (en el depósito), la grabación del director contando la plata (5 s cerca con la cámara) y la
   foto de su auto nuevo estacionado atrás.
6. **Se gana** esposando al Maestro Ernesto: sueldo de 600, un tercio menos por cada prueba que falte, cuota 400, como
   el club.
7. **Si los descubren:** el Maestro Ernesto huye en la combi del coro (lenta, con el coro adentro cantando) y arranca
   la persecución en medio del caso (decisión 101).

## Lo que se reusa
DisguisePiece (pieza nueva: túnica), ClubSuspicion y ClubMember (coristas), ClubEvidence e InfiltrationCase (con los
textos y el lugar de esta variante), ChaseCase.begin, PlaceDraw, SongMeter. Antes de programar, conviene que el club y
el coro compartan una base (la variante elige el lugar, el capo y las pruebas) en vez de copiar el código.

## El orden para hacerlo (un PR chico por paso)
1. Separar la base común de la infiltración y que el club la use. Hecho así: el club es un `InfiltrationPlace` (la base: semilla, gente
   que mira, capo, pruebas, patrullero y dónde espera la huida) y el caso (`InfiltrationCase`) juega sobre el lugar, no
   sobre el club. Lo que cambia de un lugar al otro (historia de la campaña, lo que dice el comisario, avisos, filas de
   la planilla, nombres de las pruebas, el capo y en qué huye) está en `InfiltrationCase.VARIANTS`.
2. La túnica y el cancionero en el casillero. Hecho así: en una tercera fila frente a los casilleros hay una túnica doblada y un
   cancionero por policía. La túnica se agarra y se lleva al pecho (a 22 cm de su lugar queda puesta, como la peluca)
   y se cae corriendo igual que las piezas del club. Con la túnica el policía pasa por corista (`is_disguised
   ("chorister")`), no por abuelo, y al revés. El cancionero por ahora solo se lleva en la mano; en el paso 4 se ve
   si cantar sin cancionero da sospecha **(propuesta)**.
3. La capilla en la ciudad, con los coristas, la señora de la puerta y el Maestro Ernesto. Primero (3a) la capilla sola:
   "Capilla del barrio", en la cuadra (1, 1) al sur, de 24 x 22 m y una planta: la nave con 12 bancos en dos filas y
   un pasillo al medio, la tarima del coro contra el fondo con 14 lugares y un atril delante de cada uno, el cajón del
   director, el órgano de cartón contra la pared oeste y, detrás de la tarima, la sacristía (con llave) y el depósito.
   Los policías arrancan en la comisaría, donde están las túnicas (`--place=choir`) **(propuesta)**. Después (3b) la gente:
   10 coristas con túnica y cancionero en lugares de la tarima elegidos con la semilla (quedan 4 libres para los
   policías), que cuentan un chisme distinto cada vez que les hablas (E); el Maestro Ernesto en su cajón frente al coro,
   con la batuta; y la señora de la puerta, que empuja afuera a quien no tenga túnica (un disfraz de abuelo no sirve)
   **(propuesta)**.
4. Cantar con la batuta (voz o H) y la sospecha del coro. Hecho así: a los 20 s y después cada 30 s de pausa, el Maestro
   Ernesto dirige una canción de 45 s (avisa 5 s antes). Durante la canción sube la batuta de 4 a 7 s y la baja de 2 a
   4 s (con la semilla); arriba de su cabeza se ve ▲ ♪ o ▼, suena el "aaah" del coro con la batuta arriba, y en
   pantalla "¡CANTA!" o "Silencio". Cada segundo, al policía que está en la tarima: callado con la batuta arriba suma
   +15 a los coristas a 5 m (lo oyen, miren adonde miren), y cantar con la batuta abajo (el solo) +25. Hay 0,6 s de
   margen después de cada cambio. Fuera de la tarima durante la canción, +20 por segundo a los que lo ven. Cantar es
   la voz sin cortes (el SongMeter de la fuga) o mantener H. La sospecha es la del club con otros textos: sin túnica,
   corriendo, con una herramienta en la mano o en la sacristía y el depósito. El cancionero todavía no cuenta
   **(propuesta)**.
5. Las pruebas, el caso, la combi y el sorteo. Hecho así (5a, pruebas y caso): el comisario da el caso del coro y la
   semilla elige 3 de 6 pruebas: la alcancía de la colecta con doble fondo (en un atril junto a la entrada, se agarra),
   el cuaderno del Maestro con "órgano: 0" (en la sacristía, que se abre con la llave de una maceta del depósito), la
   foto de atrás del órgano de cartón lleno de plata, los recibos del "fondo del órgano" (en el depósito), la grabación
   de dos coristas vecinos hablando de la plata y la foto del auto nuevo del Maestro, atrás de la capilla. Esposar a
   Ernesto resuelve el caso, con el mismo sueldo y la misma cuota que el club. Hasta que esté la combi (5b), si los
   descubren Ernesto huye en un auto común **(propuesta)**. Hecho así (5b, combi y sorteo): descubiertos, el Maestro
   Ernesto huye en la combi del coro (celeste y crema, con las ventanas abiertas), con cuatro coristas adentro que se ven
   y cantan el "aaah" del coro todo el camino; va a 35 km/h y se la persigue en el patrullero. Cuando se rinde, Ernesto
   se baja, los coristas se quedan y dejan de cantar. En Jugar, la infiltración sale la mitad de las veces en el club y
   la otra mitad en el coro **(propuesta)**.

## Respuestas de Cristian (22/10, decisión 101)
1. La historia va así: la colecta del órgano que nunca llega y el Maestro Ernesto.
2. Cantar se mide solo por el tiempo: cantar cuando sube la batuta y callarse cuando baja. No se mide la nota.
3. Si los descubren, el Maestro Ernesto huye en la combi del coro, con los coristas cantando adentro.
