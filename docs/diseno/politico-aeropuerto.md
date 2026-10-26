# BPD · Protección del político: En el aeropuerto (propuesta, 26/10)

Sexta variante de la protección de un político ([casos.md](casos.md), 9.7), sobre la base del acto en la plaza
([proteccion-politico.md](proteccion-politico.md), decisión 103) y del debate en televisión
([politico-debate.md](politico-debate.md), decisión 230). Esta variante es la decisión 231; las respuestas a las
preguntas del fútbol, del debate y del aeropuerto van de la 232 a la 239. Todos los números son **(propuesta)** hasta
probarlos jugando. En los textos del juego se dice "maleta", que es más neutro que "valija".

## La idea
El diputado **Pompeyo Lustre** se va de viaje a la "Cumbre de Alcaldes" y los 4 policías lo acompañan por el
aeropuerto de la ciudad hasta la puerta de embarque. Lustre compró **12 valijas iguales** (negras con una cinta
amarilla) "para confundir a los ladrones", y lo logró: confunde a todos. Su rival, la concejala **Fina Embrollo**,
le metió una valija número 13, igual a las otras, con **algo raro** adentro. Si esa valija pasa por la máquina de
rayos X delante de la prensa, el diputado queda en ridículo en todos los diarios. El chiste cooperativo, bien
físico: valijas que caen de la cinta, policías que las levantan de a una buscando la que pesa raro, se mueve o suena,
y al mismo tiempo alguien tiene que sacar al diputado de la tienda libre de impuestos.

## La historia del comisario
"Novatos, el diputado Lustre se va de viaje. Llévenlo hasta el avión con todas sus valijas. Son doce. Sí, doce. No
pregunten."

## Cómo es el caso
1. **El lugar:** un aeropuerto chico que ocupa toda la cuadra (6, 4), en la esquina este de la ciudad (sin callejón
   sin salida). La terminal (unos 40 x 24 m) mirando a la calle: el mostrador de despacho con la balanza, la cinta
   que lleva las valijas, la máquina de rayos X con una pantalla grande donde mira la prensa (3 periodistas con
   cámara), la tienda libre de impuestos, la puerta de embarque y, detrás de un vidrio, la pista con el avión y el
   carrito de equipaje.
2. **El reloj:** el embarque cierra en 4 minutos. Cada 15 s la cinta lleva una valija del mostrador a los rayos X; los
   policías pueden sacar valijas de la cinta en cualquier momento (se agarran como cualquier cosa, 20 kg).
3. **La valija rara:** una de las 13, al azar por semilla. Lo raro también sale por semilla, una de 4 (pregunta 1):
   - **Un gallo:** la valija se sacude y de vez en cuando canta.
   - **Un despertador:** suena cada 20 s durante 2 s.
   - **Un tarro de pintura abierto:** gotea pintura amarilla y deja manchas en el piso.
   - **Una pila de diarios viejos:** pesa el doble que las otras (la balanza del mostrador lo muestra).
   Además, la etiqueta de la rara dice "13" y el diputado jura que compró 12.
4. **Los rayos X:** la valija que entra a la máquina se ve en la pantalla grande. Si es una normal, se ven trajes,
   corbatas y un osito (la prensa se ríe un poco). Si es la rara, es un **papelón** y el caso se pierde (pregunta 2).
   Abrir una valija con E muestra lo que tiene, pero el diputado se queja: abrir una de las suyas que no era la rara
   es 50 menos.
5. **El diputado molesto:** cada tanto se va a la tienda libre de impuestos a probarse perfumes y lentes de sol (como
   en la plaza, se lo trae de la mano). Al cerrar el embarque tiene que estar en la puerta.
6. **El culpable:** el maletero **Tobías Cargo** trabaja para Embrollo y, si nadie lo mira, devuelve la valija rara a
   la cinta. Pistas: tiene un llavero con el logo de Embrollo, habla por teléfono en voz baja, y su carrito tiene
   cinta amarilla de sobra. Esposado, no hay más trampas. Esposar a otro empleado da 100 menos.
7. **Se gana** si el diputado sube al avión a tiempo y la valija rara nunca pasó por los rayos X. Sueldo de 600: 50
   menos por cada valija abierta de más y 100 más si el maletero quedó detenido. Cuota propia de 400, como la plaza.
8. **El final:** si el maletero sigue suelto al final, sale corriendo y se escapa en el **carrito de equipaje** por la
   calle (persecución embebida, decisión 96). Atrapado, cuenta como detenido.

## Lo que se reusa
- El diputado, su modelo y sus quejas (decisión 103); llevarlo de la mano (PoliticianWalks, como el camarín del
  debate); agarrar y cargar cosas (Grabbable); abrir con E; esposas y escolta al patrullero (OwnerEscort); la
  persecución embebida (ChaseCase.begin); la pantalla en vivo del canal de TV (SubViewport) para los rayos X; las
  pistas y el culpable del técnico del debate.
- Lo nuevo: el aeropuerto, la cinta, la balanza, la máquina de rayos X, las 13 valijas, la tienda libre de impuestos,
  el maletero, la concejala Embrollo (solo nombrada), los periodistas y el carrito de equipaje.

## El orden para hacerlo (un PR chico por paso)
1. El aeropuerto en la ciudad: la terminal, el mostrador, la cinta, los rayos X con su pantalla, la tienda, la puerta
   de embarque y la pista con el avión.
2. Las 13 valijas: agarrarlas, la cinta que las lleva, la balanza, abrirlas con E.
3. La valija rara: las 4 cosas raras y cómo se notan; los rayos X en la pantalla y el papelón.
4. El diputado en la tienda y el embarque: el reloj del caso, llevarlo de la mano.
5. El maletero comprado: pistas, esposarlo; el caso, sueldo y cuota.
6. El carrito de equipaje y el sorteo de Jugar.
7. El online.

## Preguntas para Cristian
1. **¿Qué tiene la valija rara?** Recomendado: una de 4 al azar (gallo, despertador, pintura, diarios), para que no
   se aprenda de memoria. Otra opción: siempre el gallo, que es lo más gracioso.
2. **¿Cuándo se pierde?** Recomendado: si la valija rara pasa por los rayos X o si el diputado no llega al embarque.
   Otra opción: los rayos X solo bajan el sueldo y se pierde solo si no embarca.
3. **¿Hay un culpable para esposar?** Recomendado: sí, el maletero comprado, que devuelve la valija a la cinta y huye
   en el carrito de equipaje.
