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
3. El bingo con cartón propio para cada policía.
4. La sospecha de los abuelos (reusa la del guardia) y el "¡Son policías!".
5. El baile.
6. Las 3 pruebas y el final: sueldo, Doña Chela esposada o en el andador (persecución), y el sorteo.

## Respuestas de Cristian (22/10, decisión 100)
1. La primera variante es Club de abuelos y la siguiente, Coro de iglesia.
2. El disfraz se arma con las manos en el casillero de la comisaría: cada policía agarra la peluca o el bigote como
   cualquier objeto y lo lleva a su cabeza, donde queda puesto (torcido si lo acercó mal). Si corre o se choca, se le
   puede caer adelante de los abuelos.
3. Si los descubren, arranca la persecución directa.
