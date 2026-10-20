# BPD · El interrogatorio (propuesta, 20/10)

Cuarto tipo de caso del catálogo ([casos.md](casos.md), punto 4) y decisión 27: "el sospechoso es un NPC con un
medidor de nervios y otro de abogado. Se juega a policía bueno y policía malo con acciones absurdas". Todavía no está
aprobado: todo lo que sigue es **(propuesta)** hasta que Cristian lo vea, y los números se ajustan jugando.

## La idea
Traen a un sospechoso a la comisaría y hay que sacarle una confesión antes de que llegue su abogado. No se le pega
(decisión 4): se lo pone nervioso con acciones absurdas de policía malo y se lo ablanda con acciones de policía bueno.
El chiste cooperativo es que funciona mucho mejor si dos policías se turnan: uno grita y el otro le alcanza un café.

## Dónde pasa
- **La sala de interrogatorio** ocupa el lugar de la sala de descanso, atrás a la derecha de la comisaría
  ([comisaria.md](comisaria.md)). La máquina de café que estaba ahí queda en la sala de guardia.
- Adentro: una mesa de metal atornillada al piso, dos sillas para los policías, la silla del sospechoso (esposado a la
  mesa), una lámpara de escritorio que se puede girar, el interruptor de la luz, un espejo falso y un reloj de pared.
- **La sala de observación**, del otro lado del espejo, se arma en la mitad de la sala del tablero (que sigue cerrada).
  Desde ahí se ve y se oye todo, y hay un micrófono para hablarle al policía de adentro por un parlante.

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
  interrogatorios: **1 de cada 4 turnos es un interrogatorio** y el resto, allanamientos.
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
1. La sala de interrogatorio y la de observación en la comisaría, con sus muebles.
2. El caso: el comisario lo da, el sospechoso esposado, los dos medidores, 4 acciones (mesa, lámpara, café, dona), la
   confesión, el abogado y la pantalla del turno. Con el sospechoso 1.
3. El resto de las acciones, la repetición que rinde menos y el contraste entre bueno y malo.
4. El grito con la voz.
5. El sorteo en "Jugar" (1 de cada 4).
6. Los otros 9 sospechosos, uno o dos por PR.
7. Interrogar al dueño después de un allanamiento.

## Preguntas para Cristian
1. ¿Está bien que la sala de interrogatorio reemplace a la sala de descanso, con la de observación al lado?
2. ¿Ganar con nervios a 100 y perder con abogado a 100, sin tiempo límite?
3. ¿Sueldo de 500 por confesión, igual que un allanamiento?
4. ¿Gritar con la voz de verdad cuenta como acción de malo?
5. ¿1 de cada 4 turnos es un interrogatorio?
6. ¿Te gustan los 10 sospechosos y lo que cambia cada uno?
7. ¿Hacemos lo de interrogar al dueño después de un allanamiento?
