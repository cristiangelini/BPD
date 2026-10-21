# BPD · Control de tránsito (propuesta, 21/10)

Quinto tipo de caso, del catálogo ([casos.md](casos.md), punto 8) y la decisión 32 ("casos extra: control de
tránsito..."). Cristian lo eligió el 21/10 y respondió las 3 preguntas (decisión 98). Los números siguen
**(propuesta)** hasta probarlos jugando.

## La idea
El comisario avisa que por la ciudad anda un auto buscado. Los cuatro arman un control en una esquina con conos y una
barrera, frenan los autos que pasan de a uno y revisan cada uno (los papeles, el baúl, la cara del conductor) hasta
encontrar al buscado. El chiste cooperativo es que la fila crece: mientras dos revisan, los otros tienen que dirigir el
tránsito con las manos y aguantar las bocinas y los conductores enojados.

## Cómo es el caso
1. El comisario da el caso en su oficina: "¡Novatos! Anda suelto un auto <color> con <una pista>. Armen un control en
   <esquina> y no me dejen pasar a nadie raro."
2. Se sacan del patrullero los **conos** y la **barrera** (con las manos, como todo) y se arman en la esquina marcada.
   El control funciona cuando la barrera cruza el carril.
3. Llegan autos de la ciudad (los TrafficCar que ya hay en la autopista, ahora por las calles), uno cada 6 s, y paran
   en la barrera. La fila se ve y se oye.
4. **Revisar un auto** (cada cosa la hace un policía, se pueden repartir):
   - **Papeles:** E al conductor y te da la licencia; la foto puede no coincidir.
   - **Baúl:** se abre tirando con las manos, como los muebles. Adentro puede haber contrabando, nada o un abuelo.
   - **Linterna** a la cara de noche, **soplar** (alcoholemia) en algunas variantes.
   - Cada conductor dice algo absurdo cuando lo frenan (10+ frases por tipo, con tr()).
5. **Dejar pasar o detener:** E sobre la barrera la levanta y el auto sigue. Esposar al conductor lo detiene.
6. **Medidores:**
   - **Paciencia de la fila:** sube con cada auto esperando. A 100 los autos se cuelan por la vereda, rompen conos y
     el buscado puede escaparse así.
   - **Denuncias:** detener a un inocente suma (como las multas del allanamiento) y se descuenta del sueldo. Al
     segundo inocente detenido se pierde el caso, como en el tablero de la escena del crimen.
   - No hay tiempo límite (decisión 66): solo el medidor de paciencia.
7. **Se gana** deteniendo al buscado y llevándolo al patrullero: sueldo de 500, cuota propia como la persecución
   (decisión 91). Detenido, el turno siguiente puede ser su interrogatorio (decisión 93).
8. **Se pierde** si el buscado pasa el control (con la barrera levantada o colándose): sale corriendo y arranca la
   persecución en medio del caso (decisión 96), como el culpable de la pastelería. Si se escapa también ahí, se
   pierde el caso.

## Cómo se reconoce al buscado
El comisario da 1 pista al principio y la radio suma otra cada 60 s (color del auto, una abolladura, la patente que
termina en 7, el conductor zurdo, un loro en el asiento...). La semilla elige el auto y 3 pistas; entre 15 y 25 autos
pasan por el control y hay 2 o 3 que se parecen mucho **(propuesta)**.

## Las 10 variantes (de casos.md)
| # | Variante | Lo que cambia |
|---|---|---|
| 1 | Hora pico | El doble de autos y la fila se impacienta más rápido. Primera variante a programar. |
| 2 | Caravana de payasos | Todos los autos son iguales y muy chicos; la pista está en el conductor. |
| 3 | El auto con 20 personas | Hay que hacerlas bajar y contarlas. |
| 4 | Alcoholemia en la boda | Todos van de fiesta; se sopla un tubo. |
| 5 | Carrera ilegal | Los autos pasan rápido; hay que tirar pinchos. |
| 6 | Mudanza del circo | Jaulas con animales; uno de ellos es el sospechoso. |
| 7 | Neblina | Los autos aparecen de golpe; la linterna sirve. |
| 8 | Desfile | El control queda en medio de carrozas. |
| 9 | El auto fantasma | No tiene conductor (es a control remoto). |
| 10 | Camión de frutas | El contrabando está dentro de las sandías. |

## Lo que se reusa
La ciudad (CityLayout), los autos de tránsito (TrafficCar), el patrullero, la linterna, las esposas, la escolta al
patrullero (OwnerEscort), la persecución embebida (ChaseCase.begin), el sorteo de "Jugar" (PlaceDraw), el sueldo
(ShiftReport) y la campaña. Nuevo: conos y barrera, revisar papeles y baúl, la fila con su medidor, la radio con pistas.

## Respuestas de Cristian (21/10)
1. La fila no tiene tiempo límite, solo el medidor de paciencia.
2. Al segundo inocente detenido se pierde el caso.
3. Se arranca por "Hora pico".

## El orden para hacerlo (un PR chico por paso)
1. Conos y barrera, el control que funciona en una esquina.
2. Los autos que llegan, paran y esperan; la fila y su medidor.
3. Revisar: papeles, baúl, frases de los conductores.
4. El buscado, sus pistas y la radio.
5. Detener, escoltar, sueldo, sorteo y el que se escapa (persecución).
