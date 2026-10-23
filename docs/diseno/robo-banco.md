# BPD · Robo a un banco en vivo (propuesta, 22/10)

Octavo tipo de caso, del catálogo ([casos.md](casos.md), punto 10) y la decisión 32 ("llegan cuando el robo está
pasando"). Cristian respondió las 3 preguntas el 22/10 (decisión 102). Los números son **(propuesta)** hasta probarlos jugando.

## La idea
Suena la radio: están robando el banco del barrio ahora mismo. Los cuatro llegan en el patrullero con el robo en
marcha: los ladrones adentro, los rehenes en el piso y un taladro que va abriendo la bóveda. Hay un reloj que corre
(el taladro), pero no hay tiempo límite del turno: cuando la bóveda se abre, los ladrones cargan las bolsas y huyen, y
el caso sigue como persecución. El chiste cooperativo: uno habla por teléfono con el jefe de la banda para ganar
tiempo, mientras los otros entran por atrás, sacan a los rehenes y esposan a los ladrones de a uno.

## Primera variante: Ladrones con máscaras de animales (casos.md, 10.1)
Cuatro ladrones con máscaras de animales (conejo, chancho, pato y oso; el oso es el jefe, **"El Oso"**, propuesta de
nombre). Cada uno tiene una tarea a la vista y un carácter: el conejo vigila la puerta y se asusta de todo, el chancho
cuida a los rehenes y se distrae comiendo, el pato maneja el taladro y no escucha nada, y El Oso atiende el teléfono.
Es la que mejor enseña las reglas; las otras variantes cambian una sola cosa.

## Cómo es el caso
1. **El aviso:** el comisario lo da por radio, no en su oficina (es en vivo): "¡Novatos! ¡Están robando el banco de la
   esquina! ¡Vayan ya!". Empieza con los cuatro en la comisaría y el patrullero en la puerta, como la persecución.
2. **El banco:** un lote nuevo de la ciudad. Hall con mostradores y 8 rehenes en el piso, la oficina del gerente, el
   pasillo a la bóveda (con el taladro), la puerta de atrás (con llave) y una ventilación en el techo. Afuera, la
   camioneta de la banda en la vereda.
3. **El perímetro:** al llegar, poner los conos y la barrera (los del control de tránsito) alrededor de la camioneta.
   Si la camioneta queda encerrada, la huida es a pie y más lenta.
4. **Negociar:** el teléfono del patrullero llama al banco. El que atiende habla con El Oso, que pide cosas absurdas
   (una pizza de ananá, un helicóptero de juguete, que alguien le cante el feliz cumpleaños). Cada pedido que cumplen
   frena el taladro 30 s y suelta un rehén. Mentirle (prometer y no cumplir) acelera el taladro.
5. **Entrar:** por la puerta de atrás (la llave está en el auto del gerente, que espera afuera en pijama) o por la
   ventilación (un policía levanta a otro). Adentro, cada ladrón mira hacia su tarea con un cono de visión, como el
   guardia de la fuga. Si ve a un policía, grita y los otros se ponen nerviosos: el taladro va más rápido.
6. **Esposar:** a un ladrón que no te ve se lo esposa por detrás (las esposas de siempre). Al esposado se lo escolta
   al patrullero, como al dueño del allanamiento. El conejo, si te ve, se rinde solo; el chancho suelta la comida y
   corre.
7. **Los rehenes:** se los saca de a uno, agarrándolos de la mano hasta la puerta. Si un ladrón ve que se llevan un
   rehén, sube el taladro.
8. **El taladro:** tarda 8 minutos en abrir la bóveda (propuesta), se ve en una barra arriba. Cuando la abre, los
   ladrones que queden sueltos cargan las bolsas y huyen en la camioneta (o a pie si está encerrada): arranca la
   persecución en medio del caso (decisión 96).
9. **Se gana** con El Oso esposado (adentro o al final de la persecución). Sueldo de 700: 100 menos por cada rehén que
   quede adentro y 50 menos por cada bolsa de plata que se lleven. Cuota propia, como la persecución (decisión 91).
   El Oso detenido va al interrogatorio del turno siguiente (decisión 93).
10. **Se pierde** si El Oso se escapa en la persecución.

## Las 10 variantes (de casos.md)
| # | Variante | Lo que cambia |
|---|---|---|
| 1 | Ladrones con máscaras de animales | La base. **Primera variante a programar.** |
| 2 | Rehenes que no quieren irse | Los rehenes se resisten y vuelven a sentarse si no los acompañan hasta afuera. |
| 3 | El banco del pueblo | Banco chico, un solo empleado dormido y un solo ladrón muy nervioso. |
| 4 | Robo por el techo | Los ladrones se van por el techo con un helicóptero de juguete; hay que subir antes. |
| 5 | Ladrones abuelos | Lentos pero astutos; reusa los modelos de abuelos y el andador. |
| 6 | La bóveda que se inunda | El agua sube y frena a todos (también a los ladrones). |
| 7 | Robo en el banco de sangre | Las bolsas son de sangre; los ladrones son vampiros de disfraz. |
| 8 | El ladrón arrepentido | Uno quiere devolver todo y ayuda desde adentro si lo encuentran primero. |
| 9 | Banco de semillas | Las semillas robadas crecen enseguida y llenan el banco de plantas. |
| 10 | El ladrón es el gerente | El gerente en pijama de afuera es el jefe; hay que darse cuenta antes de que se vaya. |

## Lo que se reusa
- Lote nuevo de la ciudad (CityLayout), como la capilla.
- Conos y barrera del control de tránsito; cono de visión y sospecha del guardia de la fuga; esposas y escolta del
  allanamiento; persecución embebida (ChaseCase.begin) con la camioneta; custodia e interrogatorio (decisión 93).
- El teléfono es nuevo: se habla con la voz (o con frases en pantalla si no hay micrófono).

## El orden para hacerlo (un PR chico por paso)
1. El banco (lote, hall, oficina, bóveda, puerta de atrás, ventilación) y la camioneta afuera.
2. Los ladrones (4 modelos con máscara, sus tareas y conos de visión) y los rehenes en el piso.
3. El taladro y su barra; los gritos que lo aceleran.
4. Esposar y escoltar ladrones; sacar rehenes de la mano.
5. El teléfono y los pedidos de El Oso.
6. El perímetro con conos, la huida (persecución) y el final: sueldo, cuota, custodia y sorteo de Jugar.

## Preguntas para Cristian
1. **¿Empezamos por los ladrones con máscaras de animales** (El Oso, conejo, chancho y pato)? Recomendado: sí.
2. **El teléfono con El Oso:** ¿pedidos absurdos que se cumplen para ganar tiempo (recomendado), o solo hablar por la
   voz sin reglas?
3. **El taladro de 8 minutos:** ¿está bien que el robo tenga ese reloj (recomendado), aunque los otros casos no
   tengan tiempo límite (decisión 66)? Al terminar no se pierde: arranca la persecución.

## Respuestas de Cristian (22/10, decisión 102)
1. Sí: se empieza por los ladrones con máscaras de animales.
2. Sí: el teléfono con pedidos absurdos que frenan el taladro y sueltan rehenes; mentirle lo acelera.
3. Sí: el taladro de 8 minutos; si abre la bóveda, arranca la persecución.

## Hecho así

- **Paso 1 (banco y camioneta):** el lote `bank` está en la cuadra (3, 0), lado sur, y se abre con `--place=bank`. `scenes/levels/bank.tscn` lleva al hall con la fila, los bancos y el mostrador con 3 escritorios. Atrás están la oficina, el pasillo y la bóveda, cerrada por una puerta redonda de acero (`BankLevel.vault_door`, el taladro la abre en el paso 3). La puerta de atrás tiene llave. La ventilación está en la pared oeste, a 1,5 m: no se llega saltando, pero sí subido a un compañero (propuesta). La camioneta de los ladrones (florería gris con margaritas, modelo `robbers_van`) está estacionada en el cordón. Capturas en `/mnt/project-files/banco/paso1-*.png`.
- **Paso 2 (ladrones y rehenes):** `BankRobber` con cuatro máscaras (modelos `npc_ladron_conejo/chancho/pato/oso`), cada uno en su tarea y con su cono de visión: el conejo en la entrada mira la puerta (100°, 10 m, mueve mucho la cabeza), el chancho delante del mostrador mira a los rehenes (80°, 8 m; cada 20 s come 5 s y no ve nada), el pato en el pasillo mira la bóveda (60°, 6 m, con orejeras) y El Oso detrás del escritorio del medio mira el hall (90°, 12 m). Si ven a un policía, lo gritan (`spotted`, para el taladro del paso 3). 8 rehenes (`BankHostage`) agachados en dos filas en el hall, vecinos distintos según la semilla. El pasillo ahora va derecho de su puerta a la puerta de atrás, con la bóveda al este. Capturas en `/mnt/project-files/banco/paso2-*.png`.
- **Paso 3 (taladro):** `BankDrill` (modelo `bank_drill`, en un trípode frente a la puerta de la bóveda, con el pato al lado) tarda 480 s y arranca con el nivel. Cada vez que un ladrón ve a un policía, la banda se pone nerviosa y el taladro va ×1,5 durante 20 s. `pause(s)` lo frena (para los pedidos de El Oso, paso 5) y `hurry(s)` lo acelera (para las mentiras). Barra arriba ("TALADRO DE LA BÓVEDA") con el aviso de nerviosos, parado o abierta. Al terminar, la puerta se abre hacia adentro de la bóveda y suena `opened` (para la huida del paso 6). Por ahora corre en el host; lo online va aparte. Capturas en `/mnt/project-files/banco/paso3-*.png`.
- **Paso 4 (esposar y sacar rehenes):** las esposas cierran sobre un ladrón salvo que vea a un policía a menos de 2,5 m (lo esquiva, "¡Te vi venir!", y la banda se pone nerviosa). El conejo, apenas ve a un policía, se rinde y se deja esposar de frente. El chancho suelta el sándwich y corre a la camioneta, donde se esconde para la huida del paso 6. Esposados, E los lleva del brazo al patrullero (`OwnerEscort`): dos atrás y dos en el baúl. E en un rehén lo toma de la mano: se para y sigue al policía; afuera del banco queda libre, da las gracias y se va (`BankLevel.hostages_freed`). Si un ladrón ve que se llevan un rehén, grita y el taladro se acelera. Capturas en `/mnt/project-files/banco/paso4-*.png`.
- **Paso 5 (teléfono con El Oso):** `BankPhone` es un teléfono rojo al costado del patrullero. E llama al banco y El Oso pide algo (orden al azar por semilla): una caja de donas en la puerta del banco (las vende el armero), que le canten el feliz cumpleaños por teléfono (con la voz o con H, como al guardia de la fuga, a menos de 3 m del teléfono durante 4 s) o que lleven el patrullero a otra cuadra (a más de 40 m; solo lo pide si el patrullero está cerca). Reemplazan a la pizza y el helicóptero de la idea original (Cristian lo aprobó el 22/10). E otra vez se lo promete; si nadie promete en 12 s, cuelga. Promesa cumplida en 90 s: el taladro para 30 s y suelta un rehén, que sale solo por la puerta. Promesa sin cumplir: mentira, y el taladro se acelera 30 s. Captura en `/mnt/project-files/banco/paso5-telefono.png`.
- **Paso 6a (perímetro y huida):** la barrera y 6 conos del control de tránsito esperan en la puerta de la comisaría. La camioneta queda encerrada con la barrera a menos de 3,5 m de su trompa y 4 conos parados a menos de 5 m (`BankLevel.van_boxed_in`). Cuando el taladro abre la bóveda, cada ladrón suelto se lleva una bolsa (`bags_taken`; el chancho escondido en la camioneta cuenta). Si El Oso está suelto, arranca la persecución (`ChaseCase.begin`): en la camioneta (`SuspectCar.ROBBERS_VAN`, 40 km/h) o, si está encerrada, a pie con una bolsa de plata (`BEAR_ON_FOOT`, 12 km/h, por la vereda, se lo para a pie como al andador de Doña Chela). Si El Oso ya está esposado, los demás se van con las bolsas sin persecución (Cristian lo aprobó el 22/10). Capturas en `/mnt/project-files/banco/paso6-huida-*.png`.
- **Paso 6b (el caso):** `BankCase`. El comisario lo da por radio apenas empieza el turno, con el taladro ya andando, y Q abre la planilla (rehenes sacados, esposar a El Oso, atraparlo si huye, volver a la comisaría, estado de la bóveda). Con El Oso en el patrullero (adentro o al final de la persecución) el caso está resuelto, y el turno termina cuando el patrullero vuelve a la comisaría: así pueden sacar a los últimos rehenes. Si El Oso se escapa, se pierde. Sueldo 700, 100 menos por rehén adentro y 50 por bolsa; cuota propia de 400. El Oso detenido va al interrogatorio del turno siguiente (`owner_oso`, con sus frases `BEAR_SLIP_n`). En el sorteo de Jugar sale uno de cada `BANK_EVERY` = 4 de lo que queda después de la infiltración (propuesta, como cada allanamiento). Capturas en `/mnt/project-files/banco/paso6-radio.png` y `paso6-fin-de-turno.png`.
