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

**Cómo quedó (paso 6, primera parte):** la semilla sortea el sospechoso y el comisario avisa cómo es. Ya están el que
no para de hablar (1), el abuelito tierno (3: si los nervios suben más de 25 en 5 s, llora y el abogado sube 20) y el
abogado de sí mismo (5: cada acción de malo le suma 5 más de abogado y el café no le hace nada, quiere té). Por ahora
usan los modelos del sospechoso, del abuelo y del abogado. Se fuerza uno con `--suspect=talker`, `sweet_grandpa` o
`self_lawyer`. Capturas: `sospechoso_sweet_grandpa.png` y `sospechoso_self_lawyer.png`.

**Cómo quedó (paso 6, segunda parte):** el que se duerme (6, `--suspect=sleeper`, por ahora con el modelo del preso):
si nadie hace nada en 10 s se duerme y pierde 2 de nervios por segundo. Dormido, solo lo despiertan el café, la luz, el
grito o una silla tirada; lo demás no lo oye ("Zzz... ronc..."). Captura: `sospechoso_sleeper.png`.

**Cómo quedó (paso 6, tercera parte):** el influencer (7, `--suspect=influencer`, por ahora con el modelo del
periodista): transmite en vivo. Si un policía hace de malo y nadie hizo de bueno en los últimos 8 s, el abogado sube 8
más ("¡Chicos, abuso policial en vivo! ¡Compartan, compartan!") (propuesta). Si hubo uno de bueno hace poco, la transmisión no suma.
Captura: `sospechoso_influencer.png`.

**Cómo quedó (paso 6, cuarta parte):** el peligroso (10, `--suspect=dangerous`, por ahora con el modelo del
sospechoso): cuando un policía ya entró y lo vio, si pasan 5 s sin que nadie lo mire (a menos de 12 m y 35° de donde mira,
sin paredes en el medio; el espejo falso no tapa) se suelta las esposas y corre por el pasillo, la oficina del comisario
y la sala de observación, más rápido que caminando y más lento que corriendo. Suelto, el abogado sube 1,5 por segundo y no
se le puede hacer nada. E sobre él lo agarra: uno solo lo frena a la mitad 2 s, y si otro lo agarra mientras tanto lo
atrapan entre los dos y vuelve a la silla con 15 de nervios por el susto. Jugando solo, alcanza con uno. Todo (propuesta).
Captura: `sospechoso_dangerous.png`.

**Cómo quedó (paso 6, quinta parte):** los gemelos (4, `--suspect=twins`, por ahora con el modelo del político): uno en
la sala y el otro en la primera celda de la comisaría, junto a las rejas. Cada policía trabaja al gemelo que tiene más
cerca (E, el grito y comer la dona sirven en la celda; la mesa, la lámpara y lo demás de la sala, en la sala), y arriba
hay una tercera barra con los nervios del de la celda. La semilla sortea cuál lo hizo: solo ese confiesa. Al otro también
le suben los nervios, pero lo que se le escapa es sobre su hermano ("Él tiene un lunar acá, yo no") y a 100 solo dice
que fue el otro. La carpeta del caso ahora está suelta sobre la mesa: dejarla cerca del gemelo al que no se le mostró la
última vez es el bluff "tu hermano ya habló" (+20 de nervios y +4 de abogado), así que rinde llevarla de una sala a la
otra. Todo (propuesta). Captura: `sospechoso_twins.png`.

**Cómo quedó (paso 6, sexta parte):** el mudo (2, `--suspect=mute`, por ahora con el modelo del cliente): contesta con
gestos ("*se tapa la cara con las manos y tiembla*" ante el malo, "*levanta el pulgar y sonríe*" ante el bueno). Lo que
se le escapa a 30, 60 y 90 lo dibuja en un papel que levanta para que lo vean los policías; hasta que haya arte, el papel
describe el dibujo con palabras ("Dibujo: un puente de palitos sobre la nada, con una cruz encima"). A 100 escribe la
confesión en el papel. Captura: `sospechoso_mute.png`.

**Cómo quedó (paso 6, séptima parte):** el extranjero (8, `--suspect=foreigner`, por ahora con el modelo del
sospechoso) solo habla un idioma inventado ("Nopo nopo... ¡shnurgel!"). Al lado de la mesa hay otro detenido, con el
modelo del preso, que dice que lo entiende: traduce lo que se le escapa a 30, 60 y 90 y la confesión, y a cada pista le
agrega una frase suya ("Y también dice que a mí me tienen que soltar, que soy muy buena persona"). Las reacciones no las
traduce. Captura: `sospechoso_foreigner.png`.

**Cómo quedó (paso 6, octava parte):** el fan de la policía (9, `--suspect=fan`, por ahora con el modelo del cliente):
con la primera acción confiesa tres delitos a la vez, cada uno en un papel que levanta sobre la mesa (el suyo y dos más
de la lista, en un orden que sale de la semilla). Como todavía no hay planilla, se elige con E sobre el papel: el
verdadero resuelve el caso y uno falso suma 35 de abogado y desaparece. Lo que se le escapa a 30, 60 y 90 sigue siendo
verdad, así que conviene apretarlo antes de elegir; a 100 solo pide que elijan una. Todo (propuesta). Captura:
`sospechoso_fan.png`.

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
| 4 | El gemelo | Hay dos iguales, uno en la sala y otro en la celda del carcelero, y solo uno confiesa; hay que repartirse y llevar la carpeta de uno al otro (decisión 92). |
| 5 | El abogado de sí mismo | Cada acción de malo también le sube 5 más de abogado, pero el café no le baja nada: quiere té. |
| 6 | El que se duerme | Si nadie hace nada en 10 s, se duerme y los nervios bajan; hay que despertarlo (café, luz). |
| 7 | El influencer | Transmite en vivo: si hay un policía de malo y nadie de bueno, la transmisión le suma abogado (decisión 92). |
| 8 | El extranjero | Habla un idioma inventado; el traductor es otro sospechoso que mete sus propias frases. |
| 9 | El fan de la policía | Confiesa cualquier cosa enseguida: hay que elegir en la planilla cuál de sus 3 confesiones es la verdadera. |
| 10 | El peligroso | Está esposado, pero si nadie lo mira 5 s se suelta, corre por la comisaría y hay que agarrarlo entre dos (decisión 92). |

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
6. Los otros 9 sospechosos, uno o dos por PR. Hecho.
7. Interrogar al dueño después de un allanamiento.

## Respuestas de Cristian (20/10)
1. La sala no va en la sala de descanso: es una sala de interrogatorio de película, aparte (el ala de atrás).
2. Sí: se gana con los nervios a 100 y se pierde con el abogado a 100, sin tiempo límite.
3. Sí: la confesión paga 500.
4. Sí: gritar por el micrófono cuenta como acción de policía malo.
5. Cambia: sale un interrogatorio cada 3 turnos.
6. Sí: le gustan los 10 sospechosos.
7. Sí: se puede interrogar al dueño después de un allanamiento.
