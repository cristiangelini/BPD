# Infiltración: Coro de iglesia (variante 8 de infiltracion.md)

Segunda variante de la infiltración (decisión 100). Se reusa casi todo lo del Club de abuelos: el disfraz con las
manos, la sospecha de muchos (cada corista con su medidor), las pruebas (3 de 6 por la semilla), el caso con la
planilla y el sueldo, la persecución embebida si los descubren y el sorteo de "Jugar". Lo nuevo es cantar. Todo lo que
dice **(propuesta)** espera que Cristian lo confirme.

## La historia
La capilla del barrio junta plata "para el órgano nuevo" desde hace diez años y el órgano nunca llega. El comisario
cree que el director del coro, el **Maestro Ernesto** (propuesta de nombre), se queda con las colectas. Los policías
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
   micrófono es caro y falla mucho; propongo medir solo el tiempo (cantar cuando hay que cantar) y no la nota
   **(propuesta)**.
4. **La sospecha:** como en el club, cada corista ve un cono adelante. Además de correr, las herramientas a la vista
   y entrar a la sacristía, suma cantar fuera de tiempo y la túnica que se cae.
5. **Las 3 pruebas** (la semilla elige 3 de 6): la alcancía de la colecta con doble fondo (agarrarla), el cuaderno del
   director con "órgano: 0" (en la sacristía), el órgano de cartón (sacarle una foto de atrás), los recibos del
   "fondo del órgano" (en el depósito), la grabación del director contando la plata (5 s cerca con la cámara) y la
   foto de su auto nuevo estacionado atrás.
6. **Se gana** esposando al Maestro Ernesto: sueldo de 600, un tercio menos por cada prueba que falte, cuota 400, como
   el club.
7. **Si los descubren:** el Maestro Ernesto huye en la combi del coro (lenta, con el coro adentro cantando) y arranca
   la persecución en medio del caso **(propuesta)**.

## Lo que se reusa
DisguisePiece (pieza nueva: túnica), ClubSuspicion y ClubMember (coristas), ClubEvidence e InfiltrationCase (con los
textos y el lugar de esta variante), ChaseCase.begin, PlaceDraw, SongMeter. Antes de programar, conviene que el club y
el coro compartan una base (la variante elige el lugar, el capo y las pruebas) en vez de copiar el código.

## El orden para hacerlo (un PR chico por paso)
1. Separar la base común de la infiltración y que el club la use.
2. La túnica y el cancionero en el casillero.
3. La capilla en la ciudad, con los coristas, la señora de la puerta y el Maestro Ernesto.
4. Cantar con la batuta (voz o H) y la sospecha del coro.
5. Las pruebas, el caso, la combi y el sorteo.

## Preguntas para Cristian
1. ¿Te va la historia (la colecta del órgano y el Maestro Ernesto) o preferís otra?
2. ¿Cantar se mide solo por el tiempo (cantar cuando sube la batuta) o querés que intentemos medir la nota?
3. ¿Huye en la combi del coro con los coristas cantando adentro, o en otra cosa?
