# BPD · El interrogatorio (propuesta, 20/10)

Cuarto tipo de caso del catálogo ([casos.md](casos.md), punto 4) y decisión 27: "el sospechoso es un NPC con un
medidor de nervios y otro de abogado. Se juega a policía bueno y policía malo con acciones absurdas". Cristian lo aprobó
el 20/10 (decisión 90), con dos cambios: la sala es propia y sale cada 3 turnos. Los números siguen marcados
**(propuesta)** hasta probarlos jugando.

## La idea
Traen a un sospechoso a la comisaría y hay que sacarle una confesión antes de que llegue su abogado. No se le pega
(decisión 4): se lo pone nervioso con acciones absurdas de policía malo y se lo ablanda con acciones de policía bueno.
El chiste cooperativo es que funciona mucho mejor si dos policías se turnan: uno grita y el otro le alcanza un café.

## Dónde pasa: el ala de interrogatorios
Una sala de interrogatorio de película, aparte (Cristian, 20/10: no la sala de descanso). Es un ala nueva pegada atrás
de la comisaría, de 14 × 9 m y 3,5 m de alto, en el terreno libre de la manzana. Se entra por una puerta nueva en la
pared de atrás de la oficina del comisario: para interrogar a alguien hay que pasar por al lado de su escritorio.

| Parte | Qué hay |
|---|---|
| **El pasillo** | 2 m de ancho, de punta a punta del ala, con una luz fría que titila. De ahí salen las dos puertas. |
| **La sala de interrogatorio** (8 × 7 m) | Paredes de cemento gris verdoso, sin ventanas. En el medio, la mesa de metal atornillada al piso, la silla del sospechoso (esposado a la mesa) y dos sillas para los policías. Una sola lámpara colgada sobre la mesa: el resto de la sala queda en penumbra. En la pared del oeste, el espejo falso. Arriba en una esquina, una cámara con una lucecita roja. Un reloj de pared, un grabador de cinta y una carpeta sobre la mesa, un cartel de "Prohibido fumar". |
| **La sala de observación** (6 × 7 m) | Del otro lado del espejo, que desde acá es un vidrio oscuro: se ve todo lo de adentro. Un escritorio con el equipo de grabación, dos sillas, un micrófono para hablarle al policía de adentro por un parlante y una máquina de café vieja. |

**Cómo quedó (paso 1):** el ala ya está en la ciudad, con la puerta en la oficina del comisario detrás de su
escritorio. La sala está en penumbra con la luz de la lámpara sobre la mesa, el espejo refleja la sala y desde la
observación se ve todo a través de un vidrio oscuro (y no se puede atravesar). Los muebles son placeholders low poly de
`tools/modelgen/models/interrogation.js` y la planta está en `InterrogationWing`. Capturas en
`interrogatorio/`: `sala.png`, `observacion.png`, `puerta_oficina.png` y `afuera.png`.

## Cómo es el caso
1. El comisario da el caso en su oficina, como siempre: "Detuvimos a este señor por <lo que sea>. Su abogado ya viene
   en camino. Quiero una confesión antes de que llegue."
2. El sospechoso espera esposado en la sala. Los policías entran, se sientan o se quedan parados, y empiezan.
3. **Se gana** cuando los nervios llegan a 100: confiesa, con una historia bizarra propia. Sueldo de 500 como un
   allanamiento resuelto.
4. **Se pierde** cuando el abogado llega a 100: entra el abogado, dice "Mi cliente no va a decir nada más" y se lo
   lleva. No hay sueldo de ese caso.
5. En los dos casos sale la pantalla del turno ahí mismo: no hace falta manejar el patrullero porque no salieron de la
   comisaría (la decisión 83 dice que el turno termina al estacionar; acá no hay viaje).

**Cómo quedó (paso 2):** se abre con `--place=interrogation` (todavía no sale en el sorteo de "Jugar"). El comisario da
el caso; arriba se ven los medidores de nervios y de abogado. Con E se golpea la mesa y se le apunta la lámpara a la
cara; con E sobre él se le dice "tranquilo" o, con la caja de donas de la sala de observación en la mano, se le da una.
Comerse una dona a menos de 3 m de él cuenta como policía malo. Entre dos acciones hay 1 s. El sospechoso es el que no
para de hablar, y por ahora sale uno de 4 delitos: el puente que no existe, la nariz de la estatua de la plaza, los
semáforos violetas y los patos de goma de la fuente. Todavía no se juega online. Capturas: `caso_lampara.png`,
`caso_se_le_escapa.png` y `caso_abogado.png`.

**Cómo quedó (paso 3, primera parte):** el contraste ya cuenta: una acción de bueno menos de 5 s después de una de malo
de otro policía hace que la siguiente de malo dé el doble de nervios (×1,3 si es el mismo policía). Al lado de la puerta
de la sala hay un interruptor (E: apagar y prender la luz, +8 y +5), y la máquina de café de la sala de observación sirve
un vaso (E): dejarlo en la mesa cerca de él es el café del policía bueno. Faltan la silla, el pañuelo y sentarse.
Capturas: `interruptor.png` y `observacion_vidrio.png`.

**Cómo quedó (paso 3, segunda parte):** las dos sillas de los policías están sueltas: se agarran y, si una cae fuerte
(más de 3 m/s) a menos de 4 m de él hasta 2 s después de que un policía la soltó, es la silla del policía malo
(+15, +12; cuenta una vez aunque rebote). Una silla que se cae sola no cuenta. En la mesa hay una caja de pañuelos
(E: prestarle un pañuelo, −2, −6). Falta sentarse a su lado. Capturas: `sillas_panuelos.png` y `silla_tirada.png`.

**Cómo quedó (paso 4):** gritar por el micrófono a menos de 5 m de él es el grito del policía malo (+10, +10, "¡No
me grites! ¡Tengo los oídos sensibles!"). Cuenta como grito si la voz pasa el 30% de volumen (RMS) durante 0,3 s
seguidos, una vez por grito (hay que tomar aire para el siguiente). Se mide en la PC de quien habla con la voz de
Steam, así que solo funciona con Steam abierto (V o T para hablar, o la voz siempre abierta); jugando solo sin Steam
no hay grito. Captura: `grito.png`.

**Cómo quedó (paso 5):** "Jugar" ya lo sortea: en la partida guardada el turno 3 (y el 6, el 9...) es un
interrogatorio y los demás, allanamientos; sin partida, sale 1 de cada 3 por la semilla. Como la confesión paga 500 y la
cuota del turno 3 es 1000, el turno de interrogatorio tiene cuota propia de 500 (decisión 91): confesar lo aprueba y que
venga el abogado lo pierde. Captura: `turno_3.png`.

## Los dos medidores (se ven arriba, como la denuncia del abuelo)
- **Nervios (0 a 100):** suben con el policía malo y bajan un poco con el bueno. Con 30, 60 y 90 se le escapa una frase
  que da una pista de qué hizo de verdad ("¡Yo nunca estuve en el club de golf!... Digo, ¿qué es el golf?").
- **Abogado (0 a 100):** sube con cada acción de policía malo y baja con el bueno. No sube con el tiempo (decisión 66:
  sin tiempo límite; la presión la pone el sospechoso).
- **La misma acción repetida rinde menos:** cada vez que se repite una acción seguida, sube la mitad de nervios
  ("Ya no me asusta, oficial"). Hay que variar.
- **El contraste (bueno y malo):** si un policía hace una acción de bueno menos de 5 s después de que otro hizo una de
  malo, la siguiente acción de malo da el doble de nervios. Un policía solo también puede, pero rinde menos.

## Las acciones (todas con las manos o con la voz, nada de menús)
| Policía malo (nervios +, abogado +) | Policía bueno (nervios −, abogado −) |
|---|---|
| Golpear la mesa con la mano (clic fuerte sobre la mesa): +12 nervios, +8 abogado | Alcanzarle un café de la máquina (llevar el vaso y soltarlo en la mesa): −3 nervios, −10 abogado |
| Girarle la lámpara a la cara: +10, +6 | Darle una dona de la caja: −3, −12 |
| Apagar y prender la luz: +8, +5 | Acomodarle la silla o prestarle el pañuelo: −2, −6 |
| Tirar una silla (agarrarla y soltarla de golpe): +15, +12 | Decirle "tranquilo, solo queremos ayudarte" (E mirándolo): −2, −8 |
| Comerse una dona delante de él (E con la dona en la mano): +6, +3 | Sentarse a su lado: −1, −4 |
| Gritarle con la voz (si el micrófono capta fuerte, cerca): +10, +10 | |

Romper algo de la sala (el espejo, la lámpara) suma +20 al abogado: "¡Eso es abuso policial!".

## Los sospechosos (10 variantes, una por partida, sorteada con la semilla)
Salen de [casos.md](casos.md), cada una cambia una regla:

| # | Sospechoso | Lo que cambia |
|---|---|---|
| 1 | El que no para de hablar | Con 30, 60 y 90 confiesa cosas que no tienen nada que ver; las pistas verdaderas están mezcladas. |
| 2 | El mudo | Responde con gestos: las pistas son dibujos que hace en un papel sobre la mesa. |
| 3 | El abuelito tierno | Si los nervios suben más de 25 en 5 s, llora y el abogado sube 20 solo. |
| 4 | El gemelo | Hay dos iguales en dos salas (la segunda en una celda) y solo uno confiesa; hay que repartirse. |
| 5 | El abogado de sí mismo | Cada acción de malo también le sube 5 más de abogado, pero el café no le baja nada: quiere té. |
| 6 | El que se duerme | Si nadie hace nada en 10 s, se duerme y los nervios bajan; hay que despertarlo (café, luz). |
| 7 | El influencer | Transmite en vivo: si hay un policía de malo y nadie de bueno, baja la imagen del turno. |
| 8 | El extranjero | Habla un idioma inventado; el traductor es otro sospechoso que mete sus propias frases. |
| 9 | El fan de la policía | Confiesa cualquier cosa enseguida: hay que elegir en la planilla cuál de sus 3 confesiones es la verdadera. |
| 10 | El peligroso | Está esposado, pero si nadie lo mira 5 s se suelta y hay que agarrarlo (o empieza una persecución por la comisaría). |

Además, dentro de cada variante cambian, con la semilla: el delito (sale de una lista de 10 delitos bizarros, como "le
vendió a la municipalidad un puente que no existe"), su cara y ropa, y las frases de las pistas.

## Sale como un caso más
- En "Jugar" se sortea un tipo de caso y después el lugar o el sospechoso. Mientras haya solo allanamientos e
  interrogatorios: **1 de cada 3 turnos es un interrogatorio** (Cristian, 20/10) y el resto, allanamientos.
- **Más adelante, después de un allanamiento:** si llevan al dueño esposado en el patrullero hasta la comisaría (es
  pesado y se queja todo el viaje), se lo puede interrogar para sacarle dónde está la evidencia que faltó, por la mitad
  del sueldo de esa evidencia. Es el "puede seguir a cualquier caso" de casos.md.

## Online
Los medidores, las acciones y la confesión los decide el host (decisión 50), como con la denuncia. Por la red se manda
cada acción con quién la hizo; el grito se mide en la PC de quien habla y se manda solo si pasó el umbral.

## Atajos del panel de pruebas (cuando exista)
- Forzar un interrogatorio con el sospechoso N (`--suspect=N`).
- Poner los nervios o el abogado en X.
- Hacer confesar o hacer llegar al abogado.

## El orden para hacerlo (un PR chico por paso)
1. El ala de interrogatorios detrás de la comisaría, con sus muebles, la lámpara y el espejo falso.
2. El caso: el comisario lo da, el sospechoso esposado, los dos medidores, las primeras acciones (mesa, lámpara, dar y
   comerse una dona, "tranquilo"), la repetición que rinde menos, la confesión, el abogado y la pantalla del turno. Con
   el sospechoso 1 y 4 delitos.
3. El resto de las acciones (café, silla, luz, pañuelo, sentarse) y el contraste entre bueno y malo. Hecho: el
   contraste, la luz, el café, la silla y el pañuelo.
4. El grito con la voz. Hecho.
5. El sorteo en "Jugar" (1 de cada 3). Hecho.
6. Los otros 9 sospechosos, uno o dos por PR.
7. Interrogar al dueño después de un allanamiento.

## Respuestas de Cristian (20/10)
1. La sala no va en la sala de descanso: es una sala de interrogatorio de película, aparte (el ala de atrás).
2. Sí: se gana con los nervios a 100 y se pierde con el abogado a 100, sin tiempo límite.
3. Sí: la confesión paga 500.
4. Sí: gritar por el micrófono cuenta como acción de policía malo.
5. Cambia: sale un interrogatorio cada 3 turnos.
6. Sí: le gustan los 10 sospechosos.
7. Sí: se puede interrogar al dueño después de un allanamiento.
