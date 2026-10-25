# BPD · Robo a un banco: El ladrón arrepentido (propuesta, 25/10)

Cuarta variante del robo a un banco en vivo ([casos.md](casos.md), 10.8), sobre la base de los ladrones con máscaras
de animales ([robo-banco.md](robo-banco.md), decisión 102), junto a la fiesta de los rehenes
([robo-banco-rehenes.md](robo-banco-rehenes.md), decisión 121) y los ladrones abuelos
([robo-banco-abuelos.md](robo-banco-abuelos.md), decisión 122). Todos los números son **(propuesta)** hasta probarlos
jugando. Las decisiones de esta variante usan los números 123 a 129 que quedan del hilo A.

## La idea
Es el mismo banco y la misma banda de cuatro (conejo, chancho, pato y El Oso), pero uno de los tres de abajo (nunca El
Oso) se arrepintió apenas entraron: llora debajo de la máscara, se suena la nariz con un pañuelo blanco y dice cosas
como "Mi mamá me va a matar". Quiere devolver todo, pero la banda no lo deja: si lo ven ayudando a la policía, lo
atan a una silla. El chiste cooperativo: encontrar al que llora sin que los otros te vean, darlo vuelta y cubrirlo
mientras hace sus ayudas, porque si la banda lo pesca hay que ir a desatarlo.

## La historia del comisario
"¡Novatos! ¡Roban el Banco del Barrio! Llamó un ladrón llorando, dice que quiere devolver la plata... Encuéntrenlo
antes que sus amigos."

## Cómo es el caso (lo que cambia respecto del robo base)
1. **El que llora:** la semilla elige cuál de los tres (conejo, chancho o pato) es el arrepentido. Hace su tarea como
   siempre (vigilar la puerta, cuidar rehenes, manejar el taladro), pero cada 8 s solloza: un globito con "*snif*" o
   una frase arrepentida, y se le ve el pañuelo blanco en la mano. Los otros ladrones no tienen pañuelo. Sigue mirando
   con su cono de visión, pero no grita a los policías (ver pregunta 1).
2. **Darlo vuelta:** un policía que llega al arrepentido sin que otro ladrón lo vea y aprieta E le habla: "¿Me ayudan
   a devolver todo?". Desde ahí es un aliado: no lo ven los demás conos como policía y no se lo esposa todavía.
3. **Sus tres ayudas**, de a una, caminando: (a) va a la puerta de atrás y la abre desde adentro, así no hace falta la
   llave del gerente; (b) desenchufa el taladro "sin querer": se para 60 s; (c) toma de la mano a dos rehenes y los
   saca por la puerta de atrás. Entre ayuda y ayuda vuelve a su lugar unos segundos para disimular.
4. **La banda no lo deja:** si otro ladrón lo ve en plena ayuda (su cono de visión, como con los policías) grita
   "¡Traidor!", la banda se pone nerviosa (taladro más rápido) y el arrepentido queda atado a una silla en el hall.
   Un policía lo desata manteniendo E 2 s y sigue con la ayuda que le faltaba (ver pregunta 2). Si lo atan tres veces,
   se rinde: "Ya fue, no ayudo más".
5. **La huida:** si la bóveda se abre, el arrepentido no se lleva bolsa y no huye; se sienta a esperar a la policía.
6. **Se gana y se pierde** igual que el robo base: con El Oso esposado; sueldo de 700, 100 menos por cada rehén que
   quede adentro y 50 menos por cada bolsa que se lleven; cuota propia de 400. Cada ayuda que llegó a hacer suma 50
   (hasta 150). Al final se lo esposa como a los demás y va contento: "Me lo merezco" (ver pregunta 3). Se pierde si
   El Oso se escapa.

## Lo que se reusa
Todo el banco del robo base (lote, hall, bóveda, puerta de atrás con su llave, ventilación), los conos de visión y el
"nerviosos" de la banda, el taladro con su `pause`, la mano de los rehenes, la escolta, el teléfono y la persecución.
De los abuelos se reusa el ladrón que camina a un lugar del hall. Lo nuevo: el pañuelo y los sollozos, el hablarle,
las tres ayudas, la silla con la soga y el desatar.

## El orden para hacerlo (un PR chico por paso)
1. La variante en el banco: el sorteo pasa a cuartos (fiesta, abuelos, arrepentido y base por semilla), el arrepentido
   elegido por semilla con su pañuelo, sollozos y frases.
2. Darlo vuelta con E sin que lo vean, y su primera ayuda: abrir la puerta de atrás desde adentro.
3. Las otras dos ayudas (desenchufar el taladro y sacar dos rehenes) y la vuelta a su lugar.
4. La banda que lo ve: "¡Traidor!", la silla con la soga, desatar con E y rendirse a las tres.
5. El caso (radio del comisario, planilla con las ayudas, +50 por ayuda, no huye con bolsa) y el online.

## Preguntas para Cristian
1. **¿El arrepentido es uno al azar de los tres de abajo y se lo reconoce porque llora?** Recomendado: sí, la semilla
   elige al conejo, al chancho o al pato, y se lo encuentra por el pañuelo y los sollozos. La otra opción es que sea
   siempre el mismo (el conejo, que ya es el miedoso).
2. **¿La banda lo ata a una silla si lo ve ayudando, y un policía lo desata?** Recomendado: sí, y a las tres veces
   deja de ayudar. La otra opción es que la banda solo grite y el taladro se acelere, sin atarlo.
3. **¿Al final se lo esposa igual que a los demás?** Recomendado: sí, va contento al patrullero y cada ayuda hecha
   suma 50 al sueldo. La otra opción es que quede libre y se vaya caminando como un rehén.

## Hecho así

- **Paso 1 (sorteo y el que llora):** `BankLevel.variant` reparte las semillas en cuartos: fiesta, abuelos, arrepentido
  y base (`--bank=sorry` lo fuerza). `BankLevel.sorry_animal(semilla)` elige al conejo, al chancho o al pato, y ese
  `BankRobber` tiene `sorry`: lleva un pañuelo blanco en la mano derecha, cada 8 s solloza 2 s con el pañuelo en la
  cara y una de 4 frases (`ROBBER_SORRY_SOB_1-4`), y no grita cuando ve a un policía ni a un rehén que sacan (no se
  rinde ni corre). Online el sollozo va en `net_state`. Capturas en `/mnt/project-files/arrepentido/paso1-*.png`.
- **Paso 2 (darlo vuelta y la puerta):** E sobre el que llora ("E: hablar con el que llora") lo da vuelta si ningún
  otro ladrón suelto ve a ese policía (`BankRobber.try_turn`; si no, "¡Shh! ¡Nos están mirando!"). Dado vuelta deja de
  llorar y hace sus ayudas en orden (`HELPS`, por ahora solo la puerta): camina a 1,6 m/s hasta el hueco del mostrador,
  por detrás, entra al pasillo y abre la puerta de atrás desde adentro sin llave (`FrontDoor.open_from_inside`); después
  vuelve a su lugar y descansa 5 s. El pato ya está en el pasillo y va directo. Ojo para el paso 4: el pato mira el
  pasillo, así que el chancho o el conejo pasan por delante de él. Online va `turned` en `net_state` y la copia del
  invitado no camina sola. Capturas en `/mnt/project-files/arrepentido/paso2-*.png`.
- **Paso 3 (taladro y rehenes):** las ayudas ya son las tres (`HELPS`: puerta, taladro, rehenes). Para el taladro pasa
  por al lado del pato hasta la puerta de la bóveda y lo desenchufa: se para 60 s (`BankDrill.pause`). Para los rehenes
  toma de la mano a los dos sentados más cerca del hueco del mostrador (`BankHostage.take_by`; el primero dice "¿El
  ladrón nos saca?"), los lleva por el pasillo y los saca por la puerta de atrás, donde quedan libres; si nadie queda
  sentado se saltea. Entre ayuda y ayuda vuelve a su lugar y descansa 5 s. Los caminos van por el hueco del mostrador
  entre el hall y el pasillo (`BankLevel.HALL_TO_CORRIDOR`). De paso se arregló la puerta (`front_door.tscn`): al
  abrirse, la hoja giraba a la vista pero su choque se quedaba cerrado y nadie podía pasar. Capturas en
  `/mnt/project-files/arrepentido/paso3-*.png`.
- **Paso 4 (la banda lo ata):** un ladrón suelto que ve al arrepentido en plena ayuda (no descansando en su lugar)
  grita "¡Traidor!" (`ROBBER_TRAITOR`), el taladro se pone nervioso 20 s y el arrepentido queda atado con una soga en
  una silla junto a la pared oeste del hall (`BankLevel.CHAIR_AT`, `BankRobber.tie`); suelta a los rehenes que llevaba
  y la ayuda queda sin hacer. Para desatarlo: E y quedarse a su lado 2 s (a menos de 1,6 m; si el policía se aleja se
  corta). En vez de mantener E, como decía la idea, alcanza con quedarse al lado: mantener E es un mecanismo aparte
  para cada personaje y no sumaba. Desatado vuelve a su lugar, descansa y reintenta la ayuda; a las 3 veces dice "Ya
  fue" y no ayuda más. Online va `tied` en `net_state`. Captura en `/mnt/project-files/arrepentido/paso4-atado.png`.
