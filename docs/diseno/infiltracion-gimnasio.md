# Infiltración: Gimnasio (variante 7 de infiltracion.md)

Quinta variante de la infiltración, después del Club de abuelos, el Coro de iglesia, la Banda de mimos y la Fiesta de
disfraces (decisión 172, propuesta del 25/10). Se reusa casi todo: el lugar como `InfiltrationPlace`, la gente que
mira con su medidor (`ClubMember` y `ClubSuspicion`), el disfraz con las manos, 3 pruebas de 6 por la semilla, el caso
con la planilla y el sueldo (`InfiltrationCase.VARIANTS`), la huida con persecución si los descubren y el sorteo de
"Jugar". Lo nuevo es **la rutina**: hay que entrenar de verdad, con la resistencia del policía, y **no rendirse**.
Todo lo que dice **(propuesta)** se ajusta jugando.

## La historia
La banda que roba cajas fuertes levantándolas a mano entrena en el gimnasio "Hierro Puro". El jefe es **el Toro**,
el profesor, que grita las rutinas con un silbato y no soporta a nadie que afloje. Los policías entran como socios
nuevos, juntan 3 pruebas y lo esposan... si les quedan fuerzas.

El chiste: cuatro policías con forma de pera, sin aire, haciendo sentadillas al lado de patovicas que levantan
heladeras.

## Cómo es
1. **El lugar:** "Hierro Puro", el gimnasio que ya está en la ciudad (lote de 18 x 16 m): la zona de pesas con bancos y
   mancuernas, cuatro cintas de correr contra la vidriera, el ring de boxeo en el medio, el vestuario con casilleros y
   la oficina del Toro atrás (con llave). Entre 8 y 10 socios de la banda **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay, por policía, una vincha (a la cabeza), muñequeras (a las
   manos, cuentan como una pieza) y una musculosa (al pecho). Con 2 de las 3 el policía pasa por socio
   (`is_disguised("gym")`). Con el uniforme, el de la recepción no lo deja pasar: "Sin ropa de gimnasia no se entrena"
   **(propuesta)**.
3. **La rutina (lo nuevo):** a los 20 s y después cada 40 s, el Toro toca el silbato y grita un ejercicio por la
   semilla, durante 10 s:
   - **sentadillas:** agacharse y pararse (C) al menos una vez cada 2 s;
   - **saltos:** saltar (Espacio) al menos una vez cada 2 s;
   - **cinta:** subirse a una cinta y correr (Shift) en el lugar;
   - **pesa:** agarrar una mancuerna (6 kg) y sostenerla en alto.
   Cada PC juzga a su policía una vez por segundo: si no está haciendo el ejercicio, +20 a los socios que lo ven. Los
   ejercicios gastan la resistencia del policía (la de correr); si se queda sin aire, **se rinde**: se agacha jadeando
   2 s y los socios que lo ven suman +30 ("¡Aflojó!"). Una dona en el bolsillo recupera la resistencia, como en la
   comisaría **(propuesta)**.
4. **La sospecha:** la del club con otros textos: sin disfraz ("¿Y la ropa?"), con una herramienta en la mano, en la
   oficina, una pieza del disfraz que se cae, y la rutina. A 100 un socio grita "¡Son policías! ¡Mirá cómo jadean!".
5. **Las 3 pruebas** (la semilla elige 3 de 6) **(propuesta)**:
   - la libreta de las cajas fuertes "levantadas" en la oficina (se agarra; la llave está en un bolso del vestuario);
   - foto del pizarrón de la oficina con el plan del próximo golpe;
   - la caja fuerte robada pintada como una pesa, en la zona de pesas: pesa 40 kg y hay que levantarla entre dos;
     al levantarla suenan las monedas adentro y cuenta;
   - el video de dos socios hablando del golpe mientras hacen abdominales (5 s cerca con la cámara, como el club);
   - el batido de proteínas del Toro con un mapa adentro del vaso (se agarra), en el ring;
   - el ticket del alquiler del camión de mudanzas, en un casillero del vestuario (E).
6. **Se gana** esposando al Toro: sueldo de 600, un tercio menos por cada prueba que falte, cuota de 400, igual que las
   otras infiltraciones. Esposar a un socio los descubre. Detenido, el turno siguiente puede ser su interrogatorio
   (decisión 93): se le escapan 3 frases y confiesa.
7. **Si los descubren:** el Toro sale trotando por la vereda, sin apuro y sin cansarse nunca (13 km/h), y arranca la
   persecución a pie en medio del caso. Atrapado (un policía delante, como la abuela del andador), cuenta como
   resuelto con las pruebas que tengan; si se escapa, se pierde. Es una persecución que se gana con la resistencia:
   corriendo detrás se quedan sin aire **(propuesta)**.
8. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en los mimos: la semilla (los socios, las pruebas y la rutina), cuándo hay rutina y cuál,
la sospecha de cada socio y las pruebas. Cada PC juzga a su policía (si hace el ejercicio, si se rindió) y le avisa al
host, como `MimeRehearsal` y `PartyPhoto`.

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "gym"), `ClubMember` (socios), `ClubSuspicion` (con `prefix`
"GYM_"), `ClubDoorman` (el de la recepción), `ClubEvidence` y `ClubEvidenceSpot`, `KeyPot` (el bolso con la llave),
`DisguisePiece` (tres piezas nuevas), `PlaceBuilder`, `ChaseCase` con un `SuspectCar` a pie, `PlaceDraw` y `NpcSync`.
La rutina copia la forma de `MimeRehearsal` (host decide, cada PC juzga y avisa) y usa `Cop.stamina`.

## El orden para hacerlo (un PR chico por paso)
1. El disfraz de gimnasio: vincha, muñequeras y musculosa en una fila frente a los casilleros, y el look "gym" (2 de
   3).
   Hecho así: 12 piezas en una sexta fila a 3,95 m frente a los casilleros (vincha roja con raya blanca a la cabeza,
   un par de muñequeras blancas que se ponen en las manos y una musculosa roja con raya blanca al pecho). Con 2 de 3,
   `is_disguised("gym")`. La ropa de gimnasia está hecha para transpirar: correr no la hace caer (las demás piezas sí
   se siguen cayendo), porque la rutina obliga a correr y saltar **(propuesta)**.
2. El gimnasio en la ciudad (`--place=gym`): las pesas, las cintas, el ring, el vestuario y la oficina; los socios, el
   Toro y el de la recepción.
   Hecho así (2a, el gimnasio solo): es el gimnasio "Hierro Puro" que ya estaba en la ciudad (cuadra (3, 1), al sur,
   18 x 16 m). Adentro: la recepción a la izquierda de la entrada, cuatro cintas mirando la vidriera, dos bancos con
   barra y un estante de mancuernas sobre una alfombra azul contra la pared oeste, el ring de 4 x 4 m con sogas rojas
   y dos bolsas de boxeo en el medio; atrás, el vestuario con casilleros y banco (oeste), la pared de espejos con el
   lema "¡Sin dolor no hay gloria!" donde el Toro grita la rutina, y su oficina con llave (este). 12 lugares para que
   entrenen los socios **(propuesta)**.
   Hecho así (2b, la gente): 9 socios de la banda (musculosa gris con vincha o azul con toalla al cuello, brazos
   gordos) en 9 de los 12 lugares por la semilla: los de las cintas miran la vidriera y los demás el medio del salón;
   los 3 lugares que sobran son para los policías. El Toro (musculosa roja, vincha con cuernitos, aro en la nariz y
   silbato) está frente al espejo mirando el salón. La recepcionista (chomba verde, cola de caballo y planilla) está
   entre el mostrador y la vidriera mirando la entrada y no deja pasar sin 2 piezas de gimnasia: "Sin ropa de gimnasia
   no se entrena". La sospecha es la del club con sus textos ("¡Son policías! ¡Mira cómo jadean!") **(propuesta)**.
3. La rutina: el silbato, los cuatro ejercicios, la resistencia, rendirse y la sospecha.
   Hecho así: a los 20 s y después cada 40 s (aviso del Toro 5 s antes) suena el silbato y el Toro grita un ejercicio
   por la semilla, 10 s, con el nombre y la cuenta en pantalla. Sentadillas: C para agacharse o pararse al menos cada
   2 s. Saltos: Espacio cada 2 s. Cinta: arriba de una cinta y corriendo con Shift contra la baranda. Pesa: con una de
   las 4 mancuernas de 6 kg del estante en la mano. Los socios se agachan y saltan con la rutina. Cada segundo sin
   hacerlo, +20 a los socios que lo ven. Sentadillas, saltos y pesa gastan 0,5 s de resistencia por segundo además de
   no dejarla recuperar, y la cinta gasta la mitad que correr: con la resistencia llena se aguantan los 10 s (12 s), y
   cansado no. Sin aire, el policía se rinde: jadea 2 s sin moverse y suma +30 una vez por rutina. Afuera del
   gimnasio no cuenta **(propuesta)**.
4. Las pruebas y el caso (variante "gym"): las 6 pruebas, esposar al Toro, el sueldo y el interrogatorio.
   Hecho así: la libreta (sobre el escritorio de la oficina) y la foto del pizarrón (pared este de la oficina, con una
   caja, una flecha y un camión dibujados); la llave de la oficina está en un bolso azul en el banco del vestuario
   (E). La caja fuerte pintada de pesa (negra con una franja blanca, 40 kg) está sobre la alfombra de las pesas y
   cuenta cuando se levanta 25 cm del piso, cosa que un policía solo no puede (carga 25 kg). El video de dos socios
   que entrenan juntos, el batido con un mapa en una esquina del ring y el ticket del camión en un casillero
   entreabierto (E). Esposar a un socio los descubre **(propuesta)**.
5. La huida trotando, el sorteo de "Jugar" en quintos (club, coro, mimos, fiesta y gimnasio) y online.
   Hecho así: descubiertos, el Toro sale trotando por la vereda a 13 km/h, con nubecitas de polvo detrás, y arranca la
   persecución a pie (como la Maestra Pausa); un policía delante lo frena. "Jugar" sortea la infiltración en quintos.
   Online, la huida y la rutina (el ejercicio y quién afloja) llegan a todos los PC.

## Preguntas para Cristian (decisión 172)
1. **¿La rutina gasta la resistencia y rendirse da sospecha?** Recomiendo que sí: "entrenar sin rendirse" es el caso,
   y la resistencia ya existe (correr); las donas sirven de respiro.
2. **¿Los policías se disfrazan con ropa de gimnasia (2 de 3 piezas)?** Recomiendo que sí, para mantener la regla del
   disfraz de las otras variantes.
3. **¿El Toro se escapa trotando, a pie?** Recomiendo que sí: una persecución a pie contra alguien que nunca se cansa
   es el chiste del caso, y obliga a turnarse o cortarle camino.

Mientras no respondas, se avanza con lo recomendado.
