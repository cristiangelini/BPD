# BPD · Infiltración (propuesta, 22/10)

Séptimo tipo de caso, del catálogo ([casos.md](casos.md), punto 5) y la decisión 28 ("van disfrazados y tienen que
pasar desapercibidos mientras juntan evidencia; si los descubren, hay pelea o persecución"). Cristian respondió las 3
preguntas el 22/10 (decisión 100). Los números son **(propuesta)** hasta probarlos jugando.

## La idea
El comisario sospecha de un lugar, pero no tiene pruebas para un allanamiento. Los cuatro entran disfrazados, se
mezclan con la gente y hacen lo mismo que todos (jugar al bingo, bailar) mientras juntan 3 pruebas sin que los
descubran. El chiste cooperativo: mientras uno saca una foto o revisa un cajón, los otros tienen que tapar, distraer y
seguir jugando para que nadie mire.

## Primera variante: Club de abuelos (casos.md, 5.6)
El club de jubilados del barrio hace bingo y baile los jueves. El comisario cree que es la cueva de una banda que
falsifica cartones de bingo en toda la ciudad, y el capo es la abuela que siempre gana: **Doña Chela** (propuesta de
nombre). Se reusa lo del bingo clandestino del abuelo (bolillero, cartones, la libreta) y los modelos de abuelos.

## Cómo es el caso
1. El comisario da el caso en su oficina: "¡Novatos! El club de abuelos gana demasiado al bingo. Entren disfrazados,
   junten pruebas y no se hagan notar."
2. **Disfraz:** en el casillero de la comisaría hay pelucas canosas, bigotes, bastones y chalecos de lana. Cada
   policía se pone al menos 2 cosas con las manos (agarrar la peluca y llevarla a la cabeza). Sin disfraz no entra: el
   portero los echa.
3. **El club por dentro:** salón con 12 mesas de bingo, una pista de baile, la cocina, la oficina de Doña Chela (con
   llave) y el depósito. Entre 15 y 20 abuelos.
4. **Hacer lo que hacen todos** (si no, sube la sospecha):
   - **Bingo:** cada policía tiene un cartón. Cuando sale un número que está en su cartón, tiene 6 s para marcarlo (E
     sobre el número). Si no lo marca, la vecina de mesa se da cuenta.
   - **Baile:** cada 3 minutos suena un vals y hay que ir a la pista y bailar con un abuelo o con un compañero
     (mantener apretado el ritmo que se ve en pantalla). El que se queda sentado llama la atención.
   - **Hablar con los abuelos:** cuentan chismes (10+ frases con tr()), y uno de cada cuatro deja una pista.
5. **Lo que da sospecha** (cada abuelo cercano tiene su medidor, como el guardia de la fuga):
   - Correr, sacar una herramienta a la vista (las esposas, la cámara, el kit de huellas), entrar a la oficina o al
     depósito, abrir cajones, gritar.
   - El disfraz que se cae (la peluca se cae si se choca o se corre mucho).
   - Hablar por la voz cerca de un abuelo diciendo cosas de policía no se detecta (sería injusto); solo los gritos.
   - A 100, ese abuelo grita "¡Son policías!" y se descubre a todos.
6. **Las 3 pruebas** (la semilla elige 3 de 6 posibles): fotos de la imprenta de cartones en el depósito, la libreta
   de ganancias en la oficina, los cartones marcados en el bolso de Doña Chela, la grabación de una charla (pararse 5 s
   cerca de dos abuelos que hablan, con la cámara), el bolillero cargado (todas las bolillas iguales) y el sobre con
   plata debajo del escenario.
7. **Se gana** juntando las 3 pruebas y esposando a Doña Chela (o saliendo con las pruebas y que el comisario la
   detenga después): sueldo de 600, cuota propia como la persecución (decisión 91). Detenida, el turno siguiente puede
   ser su interrogatorio (decisión 93).
8. **Si los descubren:** Doña Chela sale corriendo con la libreta en su andador con motor, y arranca la persecución en
   medio del caso (decisión 96). Si la atrapan, cuenta como ganado con las pruebas que haya: cada prueba que falta baja
   el sueldo un tercio. Si se escapa, se pierde el caso.
9. **Sin tiempo límite** (decisión 66): la presión es la sospecha y los números del bingo, que no esperan.

## Las 10 variantes (de casos.md)
| # | Variante | Lo que cambia |
|---|---|---|
| 1 | Club de ajedrez | Hay que jugar una partida (contra un abuelo que juega fatal) mientras se espía. |
| 2 | Banda de motociclistas | Pruebas de valentía: saltar con la moto, comer un ají. |
| 3 | Restaurante | Se hacen pasar por cocineros; los platos mal hechos dan sospecha. |
| 4 | Banda de mimos | Prohibido hablar: la voz cerca de un mimo da sospecha. |
| 5 | Fiesta de disfraces | Todos van disfrazados de policía y hay que encontrar al falso. |
| 6 | Club de abuelos | Bingo y baile; el capo es la abuela. **Primera variante a programar.** |
| 7 | Gimnasio | Hay que entrenar sin rendirse (aguante con la stamina). |
| 8 | Coro de iglesia | Hay que cantar (SongMeter de la fuga) y afinado. |
| 9 | Subasta de arte | Se puja con plata de la cuota; si compran algo, lo pagan. |
| 10 | Escuela de ladrones | Con buenas notas en las clases conocen al jefe. |

## Lo que se reusa
La ciudad (CityLayout, un lote nuevo para el club), el bingo del abuelo, los modelos de abuelos (modelgen), la
sospecha y la mirada del guardia de la fuga (NightGuard.sees, los medidores), la cámara de fotos, las esposas, la
persecución embebida (ChaseCase.begin), el sorteo de "Jugar" (PlaceDraw), el sueldo (ShiftReport) y la campaña. Nuevo:
el disfraz, el club, el bingo con cartón propio, el baile, la sospecha de muchos y las pruebas de infiltración.

## Online
Todo lo decide el host, como el resto de los casos: la semilla, los números del bingo, la sospecha de cada abuelo y
las pruebas. El disfraz de cada policía se ve igual en todas las PC.

## El orden para hacerlo (un PR chico por paso)
1. El disfraz: el casillero de la comisaría, ponerse y sacarse pelucas y bigotes, y que se caiga. Hecho así: frente a
   los casilleros hay una peluca canosa, anteojos y un bigote blanco por policía. Se agarran, la rueda del mouse los
   trae hasta la cara y, a menos de 22 cm de su lugar, quedan puestos (más torcidos cuanto más lejos del centro). Con 2
   piezas el policía pasa por abuelo. Corriendo 4 s se cae la pieza más torcida (1,5 s si está torcida) y chocar una
   pared corriendo la tira enseguida **(propuesta)**. El disfraz todavía no viaja de la comisaría al club (paso 2).
2. El club en la ciudad, con los abuelos, el portero y Doña Chela. Primero (2a) el club solo: "Club Años Dorados", en
   la cuadra (4, 1) al sur, de 28 x 22 m y una planta: el salón con 12 mesas de bingo, el escenario, el bolillero y la
   pista de baile, y atrás la cocina, la oficina de Doña Chela (cerrada con llave) y el depósito. Los policías arrancan
   en la comisaría, donde están los disfraces, y van en el patrullero (`--place=club`). Después (2b) los abuelos, el
   portero y Doña Chela: 16 abuelos en las sillas de las mesas (elegidas con la semilla) que cuentan un chisme distinto
   cada vez que les hablas (E), Doña Chela en el escenario detrás del bolillero, y el portero en la puerta, que empuja
   afuera a quien no tenga al menos 2 piezas de disfraz.
3. El bingo con cartón propio para cada policía. Hecho así: Doña Chela canta un número cada 8 s desde el bolillero (el
   último se ve en un cartel arriba); en 4 mesas hay un cartón libre (uno por policía, en sillas sin abuelo). La primera
   E sobre un cartón lo hace tuyo, y después E marca todos los números cantados que tiene. Un número sin marcar en 6 s
   es un error: el abuelo más cercano lo comenta (y en el paso 4 suma sospecha). Cualquiera puede marcar cualquier
   cartón, así un compañero te cubre. A los 24 números Doña Chela grita "¡BINGO!" (siempre gana ella) y empieza otra
   ronda **(propuesta)**.
4. La sospecha de los abuelos (reusa la del guardia) y el "¡Son policías!". Hecho así: cada abuelo de las mesas ve
   en un cono de 140° y 9 m delante de él. Por segundo, por cada policía que ve: sin disfraz +30, corriendo +35, con una
   herramienta en la mano +25, en la cocina, la oficina o el depósito +40; si no ve nada, baja 5. De golpe: una pieza
   del disfraz que se cae adelante suyo +30, un número del bingo sin marcar +20 al de al lado (+10 a los que están a
   3 m) y un grito a 10 m +25. A 50 sale un "?" sobre su cabeza, a 80 un "!", y a 100 grita "¡Son policías!" y Doña
   Chela sale corriendo (la persecución llega en el paso 6). Arriba de la pantalla se ve la sospecha del abuelo más
   desconfiado **(propuesta)**.
5. El baile. Hecho así: a los 2 minutos y después cada 3 suena un vals de 30 s (Doña Chela avisa 10 s antes). En la
   pista se baila apretando H en el primer tiempo de cada compás (UN, dos, tres, a 90 por minuto, con 0,22 s de
   margen), solo o con quien quieras. Un compás sin paso o un paso fuera de tiempo es un pisotón: +10 de sospecha a los
   abuelos que lo ven. El que se queda fuera de la pista durante el vals suma +20 por segundo a los que lo ven. La
   música es un "um-pa-pa" provisorio hecho en código **(propuesta)**.
6. Las 3 pruebas y el final: sueldo, Doña Chela esposada o en el andador (persecución), y el sorteo.
   - 6a. El caso: el comisario lo da en su oficina, la planilla (entrar disfrazado, pruebas 0 de 3, esposar a Doña
     Chela) y el sueldo. Esposar a Doña Chela resuelve el caso: paga 600 con las 3 pruebas y un tercio menos por cada
     una que falta. Cuota propia de 400, así que hacen falta al menos 2 pruebas para aprobar el turno. Esposar a
     cualquier otro abuelo los delata en el acto **(propuesta)**.
   - 6b. Las pruebas: la semilla elige 3 de las 6 y solo esas están en el club. La imprenta (una máquina con cartones
     en el depósito: hay que sacarle una foto), la libreta de ganancias (en el escritorio de la oficina, que se abre con
     la llave de una maceta de la cocina; cuenta al agarrarla), los cartones marcados (E sobre el bolso de Doña Chela,
     detrás de ella en el escenario), la grabación (5 s al lado de dos abuelos que hablan del negocio con la cámara en
     la mano; mientras hablan no ven nada), el bolillero cargado (cuenta al agarrarlo) y el sobre con plata (en el piso
     al pie del escenario; cuenta al agarrarlo) **(propuesta)**.
   - 6c. Descubiertos: Doña Chela se baja del escenario y sale por la puerta del club en su andador con motor (con el
     motor de una cortadora de pasto, a 10 km/h por la vereda) y arranca la persecución en medio del caso, a pie como la
     del abuelo en silla de ruedas. Si la atrapan y la llevan al patrullero, el caso cuenta como resuelto con las
     pruebas que tengan; si se escapa, se pierde **(propuesta)**. 6d. El sorteo de "Jugar".

## Respuestas de Cristian (22/10, decisión 100)
1. La primera variante es Club de abuelos y la siguiente, Coro de iglesia.
2. El disfraz se arma con las manos en el casillero de la comisaría: cada policía agarra la peluca o el bigote como
   cualquier objeto y lo lleva a su cabeza, donde queda puesto (torcido si lo acercó mal). Si corre o se choca, se le
   puede caer adelante de los abuelos.
3. Si los descubren, arranca la persecución directa.
