# Infiltración: Banda de mimos (variante 4 de infiltracion.md)

Tercera variante de la infiltración, después del Club de abuelos y el Coro de iglesia (decisión 170, propuesta del
25/10). Se reusa casi todo lo del coro: el lugar como `InfiltrationPlace`, la gente que mira con su medidor
(`ClubMember` y `ClubSuspicion`), el disfraz con las manos, 3 pruebas de 6 por la semilla, el caso con la planilla y
el sueldo (`InfiltrationCase.VARIANTS`), la huida con persecución si los descubren y el sorteo de "Jugar". Lo nuevo es
**no hablar** y el ensayo de **estatua y mímica**. Todo lo que dice **(propuesta)** se ajusta jugando.

## La historia
La compañía de mimos del barrio actúa los domingos en la plaza, y cada domingo desaparecen las billeteras del
público. El comisario cree que la jefa, la **Maestra Pausa**, entrena a los mimos para robar mientras la gente mira la
caja invisible. Los policías entran como mimos nuevos al ensayo del sábado, hacen la mímica con los demás sin decir una
palabra, juntan 3 pruebas y la esposan.

El chiste cooperativo: cuatro amigos en el chat de voz de Steam que no pueden hablar. Para pedir ayuda o avisar "¡te
mira!", hay que alejarse de los mimos o hacerse señas.

## Cómo es
1. **El lugar:** "Teatro del Silencio", un teatrito en la cuadra (5, 1) al sur, de 24 x 20 m y una planta: la sala
   con 8 filas de butacas y un pasillo al medio, el escenario contra el fondo con 14 marcas en el piso (dos filas de
   7), el banquito de la Maestra Pausa frente al escenario y, detrás, el camarín de la Maestra (con llave) y el cuarto
   de utilería. Entre 10 y 12 mimos **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay, por policía, una boina negra (a la cabeza), una cara blanca (a
   la cara, como el barbijo de la limpieza) y una remera a rayas (al pecho, como la túnica). Con 2 de las 3 el policía
   pasa por mimo (`is_disguised("mime")`). El portero es un mimo que no habla: sin disfraz, te empuja afuera con
   mímica **(propuesta)**.
3. **No hablar (lo nuevo):** mientras un policía manda voz (la cercana con V o siempre abierta, y también la radio con
   T) y está a menos de 8 m de un mimo, ese mimo lo oye, mire adonde mire: +20 de sospecha por segundo. Lejos de los
   mimos (afuera, solo en el camarín o en la utilería) se puede hablar tranquilo. Cada PC avisa al host cada 0,5 s
   que su jugador está hablando, como el canto de la fuga. Un grito suma además lo de siempre (+25). Sin Steam no hay
   voz, así que jugando por IP esta regla no pesa **(propuesta)**.
4. **El ensayo (lo nuevo):** a los 20 s y después cada 30 s, la Maestra Pausa hace sonar su silbato y empieza un ensayo
   de 40 s en el escenario. Alterna dos cosas, con la semilla:
   - **¡Mímica!** (de 4 a 7 s): todos hacen la pared invisible. El policía en el escenario mantiene H (las manos
     contra la pared). Sin H: +15 por segundo a los mimos que lo ven.
   - **¡Estatua!** (de 3 a 6 s): todos se congelan. El policía en el escenario que se mueve o mantiene H: +25 por
     segundo a los mimos que lo ven.
   - Hay 0,6 s de margen después de cada cambio. Arriba de la Maestra se ve ✋ (mímica) o ■ (estatua), y en pantalla
     "¡MÍMICA!" o "¡ESTATUA!". Fuera del escenario durante el ensayo, +20 por segundo a los que lo ven (como el coro).
   - Lo bueno: durante la estatua los mimos tampoco giran la cabeza (el cono de vista se achica a la mitad), así que
     es el mejor momento para que uno se escape del escenario a buscar pruebas... si nadie lo ve salir.
5. **La sospecha:** la del club y el coro con otros textos: sin disfraz, corriendo, con una herramienta en la mano, en
   el camarín o la utilería, una pieza del disfraz que se cae, y lo nuevo: hablar y el ensayo mal hecho. A 100 un mimo
   rompe el silencio y grita "¡Son policías!" (el único que habla en todo el caso).
6. **Las 3 pruebas** (la semilla elige 3 de 6) **(propuesta)**:
   - la caja invisible, que en realidad es de acrílico y está llena de billeteras (en la utilería; se agarra);
   - la libreta de la Maestra con lo robado cada domingo (en el camarín, que se abre con la llave de una maceta de la
     utilería; se agarra);
   - el muñeco de práctica lleno de cascabeles (en la utilería; sacarle una foto);
   - el baúl de relojes ajenos (al costado del escenario; se agarra una bolsa);
   - el video de dos mimos vecinos contándose el robo con mímica (5 s cerca con la cámara; mientras lo cuentan no ven
     nada, como la grabación del club);
   - el mapa de la plaza con cruces donde se sienta el público rico (en la pared del camarín; sacarle una foto).
7. **Se gana** esposando a la Maestra Pausa: sueldo de 600, un tercio menos por cada prueba que falte, cuota de 400,
   igual que el club y el coro. Esposar a otro mimo los delata en el acto. Detenida, el turno siguiente puede ser su
   interrogatorio (decisión 93): se le escapan 3 frases y confiesa con mímica.
8. **Si los descubren:** la Maestra Pausa sale por la puerta del teatro "manejando" un auto invisible (corre a pie
   con las manos en un volante que no existe, a 14 km/h por la calle) y arranca la persecución en medio del caso, a pie
   como la de Doña Chela en el andador. Atrapada y llevada al patrullero, cuenta como resuelto con las pruebas que
   tengan; si se escapa, se pierde **(propuesta)**.
9. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en el coro: la semilla, el ensayo (mímica o estatua y cuánto dura), la sospecha de cada
mimo y las pruebas. Cada PC juzga a su policía (si mantiene H, si se mueve en la estatua, si está hablando) y le avisa
al host, como `ChoirSinging`.

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "mime"), `ClubMember` (mimos con otros modelos y chismes que son
solo mímica: "*hace como que llueve*"), `ClubSuspicion` (con `prefix` "MIME_"), `ClubDoorman`, `ClubEvidence` y
`ClubEvidenceSpot`, `DisguisePiece` (tres piezas nuevas), `PlaceBuilder`, `ChaseCase.begin` con un `SuspectCar` nuevo a
pie, `PlaceDraw` y `CaseSync`. El ensayo copia la forma de `ChoirSinging` (host decide, cada PC juzga y avisa).

## El orden para hacerlo (un PR chico por paso)
1. El disfraz de mimo: boina, cara blanca y remera a rayas en una cuarta fila frente a los casilleros, y el look
   "mime" (2 de 3). Hecho así: 12 piezas en una fila a 3,15 m frente a los casilleros (boina a la cabeza, cara blanca
   a la cara, remera a rayas doblada que se lleva al pecho, como la túnica); se caen corriendo como las del club. Con 2
   de 3, `is_disguised("mime")`; no sirven para abuelo ni para corista.
2. El teatro en la ciudad (`--place=mime`), con los mimos en sus marcas (por la semilla), el portero mudo y la Maestra
   Pausa. Hecho así (2a, el teatro solo): lote de 24 x 20 m en la cuadra (5, 1) al sur; la sala con 8 filas de butacas
   en dos bloques y el pasillo al medio, el escenario de 16 x 3,5 m y 0,35 de alto con 14 cruces de cinta (dos filas de
   7, a 2 m), telones rojos a los costados, el baúl al este del escenario, el banquito de la Maestra frente a él y,
   atrás, el camarín (oeste, con llave, espejo con lamparitas) y la utilería (este, estantes y cajas)
   **(propuesta)**.
3. No hablar: la voz cerca de un mimo suma sospecha (VoiceChat avisa al host).
4. El ensayo: estatua y mímica con H, la vista de los mimos durante la estatua.
5. Las pruebas y el caso (variante "mime" en `InfiltrationCase.VARIANTS`).
6. La huida en el auto invisible, el sorteo de "Jugar" en tercios (club, coro, mimos) y online.

## Preguntas para Cristian (decisión 170)
1. **¿Hablar por la radio también da sospecha?** Recomiendo que sí: si la radio no cuenta, todos hablan con T y se
   pierde el chiste de no poder hablar. Lejos de los mimos se habla libre.
2. **¿El ensayo es estatua y mímica con H, o copiar 4 poses con teclas?** Recomiendo estatua y mímica con H: usa el
   mismo ritmo del coro, no ocupa las teclas 1 a 4 del cinturón, y la estatua da el momento para escaparse a buscar
   pruebas.
3. **¿La Maestra Pausa huye a pie en un auto invisible?** Recomiendo que sí: es el chiste de un mimo, se reusa la
   persecución a pie del andador y no hace falta un vehículo nuevo.

Mientras no respondas, se avanza con lo recomendado.
