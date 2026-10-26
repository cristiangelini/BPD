# BPD · Protección del político: La fiesta de cumpleaños (propuesta, 26/10)

Variante de la protección de un político ([casos.md](casos.md), 9.8), sobre la base del acto en la plaza
([proteccion-politico.md](proteccion-politico.md), decisión 103). Todos los números son **(propuesta)** hasta
probarlos jugando. La decisión de esta variante es la 221 (de las 220 a 229).

## La idea
El diputado **Pompeyo Lustre** cumple 50 y se festeja a sí mismo en la plaza, con globos, guirnaldas y una mesa
larga sobre el escenario. Le regalaron tres pasteles y va a soplar las velas de cada uno, uno por uno, mientras el
público le canta. Uno de los tres es una trampa de su rival: adentro tiene un resorte con un kilo de crema que le
salta a la cara cuando sopla. El chiste cooperativo: uno pega la oreja a cada pastel para escuchar el tic tac, otro
lee las tarjetas, y dos cargan el pastel trucho (pesa mucho) hasta la fuente, mientras el resto sigue frenando huevos.

## La historia del comisario
"Novatos, el diputado Lustre cumple años y lo festeja en la plaza. Le mandaron tres pasteles y uno no viene de buena
fe. Que sople las velas tranquilo. Y guárdenme una porción."

## Cómo es el caso
1. **La plaza:** la misma del acto base, con el escenario vestido de fiesta: guirnaldas, globos y una mesa larga con
   mantel. Todo lo de la base sigue igual: el público, los que tiran huevos y tomates, las manchas, bajarse a saludar
   y llevarlo de la mano.
2. **El reloj:** en lugar del discurso, la fiesta dura 6 minutos. A los 2, a los 4 y a los 6 minutos el diputado se
   para frente a un pastel, el público canta el feliz cumpleaños 10 s y sopla. Se sabe cuál es el siguiente: tiene las
   velas prendidas.
3. **Los tres pasteles:** de chocolate, de fresa y de crema, al azar por semilla, cada uno con su tarjeta ("De la
   comisión de festejos", "De la panadería del barrio", "De un admirador secreto"...). Uno de los tres, al azar, es la
   trampa. Las tarjetas son de una lista de 10 y no delatan solas: el trucho puede tener cualquiera.
4. **Escuchar:** con E pegado a un pastel, el policía escucha 3 s: el trucho hace "tic tac" (se ve un ícono y se oye
   por la voz de proximidad); los otros no hacen nada. Escuchar no lo desarma.
5. **Llevárselo:** el pastel trucho es un objeto con física de 30 kg: se carga entre dos, como la caja fuerte. Tirado
   en la fuente se arruina y ya no sirve. Sacar un pastel bueno de la mesa hace que el diputado se queje ("¡Ese era el
   de la panadería!") y es una mancha en su imagen.
6. **Si sopla el trucho:** lo que pasa sale de la pregunta 3.
7. **El que lo trajo:** un repartidor con gorra de la "Pastelería Sorpresa" está entre el público. Pistas: la gorra,
   y que se ríe solo cuando el diputado se acerca a un pastel. Esposado, se lo escolta al patrullero como a los que
   tiran y suma 100. Si sigue suelto al final, huye en el monopatín (en lugar del último que tira).
8. **Se gana** si la fiesta termina con menos de 10 manchas, como la base. Sueldo de 600: 50 menos por mancha, 50
   más por cada uno que tiraba detenido, 100 más si el repartidor quedó detenido y 100 más si el diputado sopló los dos
   pasteles buenos (le gusta soplar). Cuota de 400, como la plaza.

## Lo que se reusa
- Todo el acto de la plaza: `PlazaRally` y su escenario, `RallyCrowd`, los huevos y tomates, las manchas (también las
  de imagen, `Politician.SHAME`, del doble), bajarse a saludar, esposas, escolta al patrullero, el monopatín y la
  persecución embebida.
- Cargar entre dos como la caja fuerte y la fuente de la plaza que ya existe.
- Lo nuevo: la mesa y la decoración, los tres pasteles con sus velas y sus tarjetas, escuchar el tic tac, el resorte
  de crema, el canto del público y el repartidor.

## El orden para hacerlo (un PR chico por paso)
1. La fiesta en la plaza: el sorteo de los actos pasa a cuartos (`--place=birthday`), la mesa, la decoración, los tres
   pasteles con sus tarjetas y velas, y el reloj de la fiesta con los tres soplidos y el canto.
2. El pastel trucho: escuchar el tic tac, cargarlo entre dos, la fuente, sacar uno bueno, y qué pasa si lo sopla.
3. El repartidor (gorra, risa, esposarlo, escolta), el sueldo, la huida en monopatín y el online.

## Preguntas para Cristian
1. **¿Cómo se encuentra el pastel trucho?** Recomendado: pegando la oreja (E de cerca, 3 s): el trucho hace tic tac.
   Así hay que ir de pastel en pastel. La otra opción es probarlos (comer un pedazo con la tecla de la dona) y el que
   come el trucho se lleva la crema en la cara.
2. **¿Qué se hace con el trucho?** Recomendado: cargarlo entre dos (30 kg) y tirarlo en la fuente. La otra opción es
   desarmarlo ahí mismo sacándole la vela del medio con las manos.
3. **¿Qué pasa si el diputado sopla el trucho?** Recomendado: le salta la crema a la cara, son 3 manchas y llora 10 s
   sin moverse; la fiesta sigue. La otra opción es que se vaya furioso y el caso se pierda.

## Hecho así
- **Paso 1 (la fiesta, la mesa y los tres pasteles):** `--place=birthday` abre `scenes/levels/plaza_birthday.tscn`, la
  misma plaza del acto con `PlazaRally.variant = "birthday"`, y el sorteo de Jugar reparte las protecciones en cuartos
  (plaza, mercado, doble y cumpleaños, `PlaceDraw.RALLIES`). El escenario tiene banderines sobre el cartel ("¡Felices
  50, diputado Lustre!") y una mesa larga con mantel al oeste del atril, con los tres pasteles (`BirthdayCake`): uno de
  cada sabor, cada uno con su tarjeta delante, sabores y tarjetas sacados con la semilla. El reloj es el discurso, que
  tiene 12 frases de cumpleaños propias. `BirthdayParty` lo lleva al pastel con las velas prendidas a los 2 y 4 minutos
  y a los 5:50 (no a los 6, para que el último se sople antes del final), solo si está en el atril: si anda saludando, el
  pastel espera. El público canta 10 s, él sopla, vuelve al atril y se prenden las velas del siguiente. La planilla
  cuenta los pasteles soplados. Capturas en `/mnt/project-files/cumple/paso1-*.png`.
- **Paso 2 (el pastel trucho):** uno de los tres, al azar con la semilla (puede ser de cualquier sabor), tiene el resorte
  y pesa 30 kg (`BirthdayCake.RIGGED_KG`: más de lo que carga un policía, así que hacen falta dos). Con E cerca de un
  pastel el policía pega la oreja 3 s (si se aleja más de 1,8 m, deja de escuchar): el trucho muestra "♪ tic tac ♪"
  encima 4 s y le dice que lo lleve a la fuente; los buenos no hacen nada. Todavía no hay sonido, solo el cartel. En la
  fuente (dentro del agua) se arruina, ya no se puede escuchar y la fiesta se lo saltea. Un pastel bueno sacado de la
  mesa es una mancha de imagen y el diputado protesta; cuando le toca, se lo saltea ("¿Y mi pastel?"). Si sopla el
  trucho, le salta el resorte con la crema: 3 manchas de crema en la cara y llora 10 s sin moverse, después vuelve al
  atril y la fiesta sigue. Capturas en `/mnt/project-files/cumple/paso2-*.png`.
- **Paso 3 (el repartidor, el sueldo y el online):** el repartidor (`PlazaRally.courier`, un vecino más con la cara del
  repartidor) espera en la punta oeste, entre las dos filas del público, con la gorra rosa de la "Pastelería Sorpresa"
  más grande de lo normal. Puede haber otros repartidores comunes en el público, sin la gorra rosa. Cada vez que el
  diputado va hacia un pastel, se ríe solo. Con E habla como cualquiera. Esposado confiesa ("¡Yo solo hago entregas!"), se
  lo lleva al patrullero con E y suma 100 (fila en la planilla). Los dos pasteles buenos soplados suman otros 100. Si
  sigue suelto al final, huye él en el monopatín (después del doble, antes que los que tiran) con su cara y sus frases
  (`ChaseSuspect.COURIER`); atrapado, suma los 100. Online el host decide la fiesta: los pasteles de los invitados
  siguen los del host (velas, soplado, en la fuente, el resorte) por el snapshot del caso, y el repartidor va por
  `NpcSync`. Captura en `/mnt/project-files/cumple/paso3-repartidor.png`.
