# Infiltración: Fiesta de disfraces (variante 5 de infiltracion.md)

Cuarta variante de la infiltración, después del Club de abuelos, el Coro de iglesia y la Banda de mimos (decisión
171, propuesta del 25/10). Se reusa casi todo: el lugar como `InfiltrationPlace`, la gente que mira con su medidor
(`ClubMember` y `ClubSuspicion`), el disfraz con las manos, 3 pruebas de 6 por la semilla, el caso con la planilla y
el sueldo (`InfiltrationCase.VARIANTS`), la huida con persecución si los descubren y el sorteo de "Jugar". Lo nuevo es
que **el jefe no tiene cara conocida**: hay que encontrarlo entre invitados iguales con las pistas, y la **foto
grupal**. Todo lo que dice **(propuesta)** se ajusta jugando.

## La historia
Una banda de ladrones de joyas festeja su último golpe con una fiesta de disfraces en el Salón Gala, y el chiste de la
banda es que todos van disfrazados de policía. El jefe, **el Sargento Trucho**, está entre los invitados, pero nadie
sabe cuál es: todos tienen gorra, bigote postizo y placa de plástico. Los policías entran disfrazados... de policías de
disfraz, juntan 3 pistas sobre cómo va vestido el jefe y lo esposan a él y no a otro.

El chiste: cuatro policías de verdad que tienen que parecer policías de mentira. Con el uniforme solo, los invitados
dicen "¡Qué disfraz tan real!" y empiezan a sospechar.

## Cómo es
1. **El lugar:** "Salón Gala", un salón de fiestas de una planta de 24 x 20 m: la pista de baile con una bola de
   espejos en el medio, la mesa larga de comida, una escalerita de tres escalones contra el fondo para la foto grupal,
   el guardarropa junto a la entrada, el baño y, atrás, la oficina del salón (con llave, ahí está la caja fuerte de la
   banda). Entre 10 y 12 invitados **(propuesta)**.
2. **El disfraz (al revés):** en el casillero de la comisaría hay, por policía, un bigote postizo (a la cara), una
   placa de plástico gigante (al pecho) y una gorra de cotillón con luces (a la cabeza). Con 2 de las 3 el policía pasa
   por "policía de disfraz" (`is_disguised("party")`). Con el uniforme solo, el patovica de la puerta no lo deja
   entrar: "Es una fiesta de disfraces, no de policías de verdad" **(propuesta)**.
3. **Los invitados y sus rasgos (lo nuevo):** cada invitado tiene, por la semilla, 4 rasgos de su disfraz: el color de
   la gorra (azul, negra o blanca), el bigote (finito, de manubrio o tupido), la placa (dorada, plateada o de
   chocolate) y los lentes (de sol, de corazón o ninguno). La semilla elige al jefe y arma a los demás para que con
   las 3 pistas del caso haya **uno solo** que coincida. Al hablarles (E), los invitados cuentan chismes de la fiesta;
   ninguno dice quién es el jefe.
4. **La foto grupal (lo nuevo):** a los 25 s y después cada 45 s, el fotógrafo grita "¡Foto grupal!": todos van a la
   escalerita y hay 8 s para llegar. Después cuenta "3, 2, 1" y hay que quedarse quieto en la escalerita hasta el
   flash. Lejos de la escalerita en el flash: +30 a los invitados que lo ven; moverse en la escalerita durante la
   cuenta: +25 por segundo, como la estatua de los mimos. Durante la foto **el jefe no posa**: se escapa a la oficina a
   contar las joyas (la puerta queda abierta 11 s). El que se arriesga a faltar a la foto y lo ve en la oficina se
   lleva una pista (el rasgo que la semilla no dio todavía) **(propuesta)**.
5. **La sospecha:** la del club con otros textos: sin disfraz ("¡Qué disfraz tan real!"), corriendo, con una
   herramienta en la mano, en la oficina, una pieza del disfraz que se cae y la foto grupal. A 100 un invitado grita
   "¡Son policías de verdad!".
6. **Las 3 pistas** (la semilla elige 3 de 6, de rasgos distintos; cada una dice un rasgo del jefe y se anota sola en
   la planilla del caso, "El jefe: gorra azul, ¿?, placa de chocolate") **(propuesta)**:
   - el ticket del guardarropa del jefe, con su gorra anotada (en el guardarropa; se agarra) - gorra;
   - un pelo de bigote en la bolsa de joyas escondida en el baño (sacarle una foto) - bigote;
   - la foto del año pasado colgada en la oficina, con el jefe marcado con un círculo (foto) - placa;
   - el video de dos invitados vecinos chismeando sobre el jefe (5 s cerca con la cámara, como el club) - el rasgo que
     falte;
   - la boleta de la óptica en la mesa de comida (se agarra) - lentes;
   - la anfitriona, la señora Serpentina, que no es de la banda y cuenta lo que vio si se le habla sin invitados cerca
     (a 6 m) - el rasgo que falte.
7. **Se gana** esposando al Sargento Trucho: sueldo de 600, un tercio menos por cada pista que falte, cuota de 400,
   igual que las otras infiltraciones. Esposar a un invitado equivocado: la primera vez el invitado se queja, todos
   los invitados suman +50 y se lo suelta solo; la segunda vez los descubren **(propuesta)**. Detenido, el turno
   siguiente puede ser su interrogatorio (decisión 93): se le escapan 3 frases y confiesa.
8. **Si los descubren:** el Sargento Trucho sale corriendo y se escapa en un patrullero de cotillón (un auto común
   con una sirena de juguete en el techo que suena desafinada), y arranca la persecución en auto en medio del caso,
   como la de Doña Chela. Atrapado y llevado al patrullero, cuenta como resuelto con las pistas que tengan; si se
   escapa, se pierde.
9. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en los mimos: la semilla (los rasgos y el jefe), la foto grupal (cuándo, la cuenta y el
flash), la sospecha de cada invitado y las pistas. Cada PC juzga a su policía (si está en la escalerita, si se mueve)
y le avisa al host, como `ChoirSinging` y `MimeRehearsal`.

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "party"), `ClubMember` (invitados con disfraces armados por
partes), `ClubSuspicion` (con `prefix` "PARTY_"), `ClubDoorman` (el patovica), `ClubEvidence` y `ClubEvidenceSpot`,
`DisguisePiece` (tres piezas nuevas), `PlaceBuilder`, `ChaseCase.begin` con un `SuspectCar`, `PlaceDraw` y `NpcSync`.
La foto grupal copia la forma de `MimeRehearsal` (host decide, cada PC juzga y avisa).

## El orden para hacerlo (un PR chico por paso)
1. El disfraz de policía de cotillón: bigote postizo, placa de plástico y gorra con luces en una quinta fila frente a
   los casilleros, y el look "party" (2 de 3). Hecho así: 12 piezas en una fila a 3,55 m frente a los casilleros
   (gorra azul con dos lucecitas a la cabeza, bigote negro de manubrio a la cara, estrella dorada de plástico al
   pecho); se caen corriendo como las otras. Con 2 de 3, `is_disguised("party")`; no sirven para mimo ni abuelo.
2. El salón en la ciudad (`--place=party`), con los invitados y sus 4 rasgos por la semilla (un solo jefe posible
   con 3 rasgos), el patovica y la señora Serpentina.
   Hecho así (2a, el salón solo): lote de 24 x 20 m en la cuadra (5, 0) al sur, fachada violeta con globos. Adentro, la
   pista de 8 x 8 m a cuadros con la bola de espejos, la mesa larga de comida contra la pared oeste, tres escalones
   rojos de 12 m de ancho contra el fondo (0,2 m cada uno, 6 lugares por escalón para la foto) con el cartel "¡Gran
   fiesta de policías!", el guardarropa con mostrador y percha al oeste de la entrada, el baño al este y la oficina
   (con llave, escritorio y caja fuerte) en la esquina del fondo al este. 16 lugares para que los invitados charlen.
   Hecho así (2b, la gente): 12 invitados en 12 de los 16 lugares por la semilla, con el disfraz celeste de cotillón y
   sus 4 rasgos puestos encima (gorra azul, negra o blanca con estrellita; bigote finito, de manubrio o tupido; estrella
   dorada, plateada o de chocolate en el pecho; lentes de sol, de corazón o ninguno). Cada otro invitado difiere del
   Sargento Trucho en al menos 2 rasgos, así que cualquier trío de pistas lo señala solo a él. Todos, el jefe también,
   cuentan los mismos chismes de la fiesta. La señora Serpentina (vestido rosa de lentejuelas y gorrito) está junto al
   ponche y no es de la banda; el patovica (remera negra y lentes oscuros) echa al que llega de uniforme. La sospecha
   es la del club con los textos "PARTY_" **(propuesta)**.
3. La foto grupal: la llamada, la escalerita, la cuenta y el flash; la sospecha; el jefe que se va a la oficina y la
   pista de verlo ahí.
   Hecho así: la que saca la foto es la señora Serpentina (no hay fotógrafo aparte). A los 25 s y después cada 45 s
   grita "¡Foto grupal!", los invitados caminan 2 s hasta lugares de la escalerita elegidos con la semilla (quedan 7
   para los policías), mirando al salón, y ella se para enfrente. A los 8 s cuenta "3, 2, 1" (en pantalla) y cada PC
   juzga a su policía una vez por segundo: en la escalerita y caminando más de 30 cm, +25 a los que lo ven. En el
   flash (con clic, luz y la pantalla blanca), el policía que está en el salón y no en la escalerita suma +30 a los que
   lo ven. Mientras tanto el jefe entra por la puerta de la oficina (que abre y después cierra, sin llave) y cuenta
   joyas frente a la caja fuerte; el policía que está en la oficina en ese momento lo ve, una vez por foto (la pista
   llega en el paso 4) **(propuesta)**.
4. Las pistas y el caso (variante "party"): las 6 pistas, la planilla con los rasgos, esposar al jefe o a uno
   equivocado, el sueldo y el interrogatorio.
5. La huida en el patrullero de cotillón, el sorteo de "Jugar" en cuartos (club, coro, mimos y fiesta) y online.

## Preguntas para Cristian (decisión 171)
1. **¿El jefe se encuentra por pistas de su disfraz entre invitados iguales?** Recomiendo que sí: es "encontrar al
   falso" del catálogo, y cambia la infiltración de "juntar pruebas" a "deducir", como la escena del crimen.
2. **¿Los policías se disfrazan de policía de cotillón, o entran con el uniforme de verdad?** Recomiendo el cotillón
   (2 de 3 piezas): el chiste de parecer policía de mentira, y se mantiene la regla del disfraz de las otras
   variantes.
3. **¿Esposar a un invitado equivocado los delata en el acto?** Recomiendo dar una oportunidad: la primera vez suma
   +50 a todos los invitados y la segunda los delata. Con 3 pistas de rasgos se puede adivinar, pero un error de
   lectura no debería terminar el caso.

Mientras no respondas, se avanza con lo recomendado.
