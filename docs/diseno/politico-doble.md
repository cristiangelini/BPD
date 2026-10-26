# BPD · Protección del político: El doble (propuesta, 26/10)

Variante de la protección de un político ([casos.md](casos.md), 9.10), sobre la base del acto en la plaza
([proteccion-politico.md](proteccion-politico.md), decisión 103). Todos los números son **(propuesta)** hasta
probarlos jugando. La decisión de esta variante es la 220 (de las 220 a 229).

## La idea
El diputado **Pompeyo Lustre** vuelve a la plaza, pero esta vez son dos. Su rival contrató a **Rolo Calcado**, un
actor que lo imita igualito, para que se suba al escenario y diga barbaridades por el micrófono ("¡Voy a cerrar la
comisaría y poner un estacionamiento!"). Cada vez que el verdadero se baja a saludar a la gente, el doble se cruza por
detrás del escenario y toma su lugar. El chiste cooperativo: uno lee el expediente con cómo es el verdadero, otro mira
de cerca al que está en el atril y el tercero espera con las esposas a que le den la señal. Si esposan al equivocado,
el diputado se ofende muchísimo.

## La historia del comisario
"Novatos, el diputado Lustre habla otra vez en la plaza. Dicen que anda suelto un imitador que se le parece como una
gota de agua. Les dejo la ficha del diputado. Esposen al falso, no al verdadero: el verdadero me firma el presupuesto."

## Cómo es el caso
1. **La plaza:** la misma del acto base, con el escenario, los vecinos y los cuatro que tiran huevos y tomates. Todo lo
   de la base sigue igual: discurso de 6 minutos, manchas, bajarse a saludar y llevarlo de la mano.
2. **El doble:** Rolo Calcado usa el mismo modelo del diputado, con 3 diferencias chicas que salen al azar con la
   semilla, de una lista de 10: el reloj en la otra muñeca, las medias rojas en lugar de grises, el prendedor del
   partido al revés, el bigote un poco torcido, una curita en la mano, la corbata a lunares en lugar de a rayas, el
   pelo con la raya del otro lado, un zapato de cada color, los anteojos en el bolsillo en lugar de puestos y una
   mancha de café en la camisa. Todo se ve más grande de lo normal, como las manos sucias de los que tiran, para que se
   pueda encontrar a 3 o 4 m.
3. **La ficha:** con Q, en la planilla del caso, aparece la ficha del verdadero: cómo son esas 10 cosas en él (por
   ejemplo "reloj en la muñeca izquierda"). Así se compara lo que se ve con lo que dice la ficha.
4. **El cambiazo:** al principio el verdadero está en el atril y el doble está escondido entre los vecinos, con
   sombrero y bufanda (no se le ven las diferencias). Cada vez que el verdadero baja a saludar, el doble se escabulle
   por detrás del escenario, se saca el sombrero y sube al atril. El verdadero, cuando vuelve, se pone a saludar al pie
   del escenario quejándose de que "alguien me robó el lugar". Desde ahí los dos se mueven igual y se cruzan cada vez
   que alguno baja: hay que volver a mirar.
5. **Las barbaridades:** cuando el doble está en el atril, en vez de las frases del discurso dice una de 10
   barbaridades cada 10 s. Cada una es una mancha de imagen en el traje del verdadero (cuenta para las 10 manchas de la
   base). Los huevos y tomates le pegan igual a cualquiera de los dos, pero solo las manchas del verdadero cuentan.
6. **Esposar:** los dos se esposan con las esposas de siempre, estén arriba o abajo. Al doble esposado se le cae el
   bigote ("¡Era un trabajo! ¡Me pagaban por hora!") y con E se lo escolta al patrullero, como a los que tiran. Desde
   ahí el verdadero da el discurso solo, como en la base.
7. **El equivocado:** lo que pasa si esposan al verdadero sale de la pregunta 2.
8. **Se gana** si termina el discurso con menos de 10 manchas, como en la base. Sueldo de 600: 50 menos por mancha, 50
   más por cada uno de los que tiran detenido y 150 más si el doble quedó detenido. Cuota de 400, como la plaza.
9. **El final:** si el doble sigue suelto cuando termina el discurso, huye corriendo con el sombrero en la mano y
   empieza la persecución a pie (ChaseCase.begin, decisión 96), como el del monopatín de la base. Si también queda
   suelto uno de los que tiran, huye ese en el monopatín y el doble a pie. Atrapado, cuenta como detenido.

## Lo que se reusa
- Todo el acto de la plaza: `PlazaRally`, el escenario, `PoliticianSpeech`, `RallyCrowd`, los huevos y tomates
  (`RallyThrowable`), las manchas (`Politician.stain`), bajarse a saludar y llevarlo de la mano (`PoliticianWalks`),
  esposas, escolta al patrullero y la persecución embebida.
- La ficha en la planilla (Q), como la planilla del caso de siempre.
- Lo nuevo: el doble (otro `Politician` con sus diferencias), las 10 diferencias, la ficha, el cambiazo detrás del
  escenario, las barbaridades y esposar al verdadero.

## El orden para hacerlo (un PR chico por paso)
1. El doble en la plaza: el sorteo de los actos pasa a tercios (`--rally=double` lo fuerza), Rolo escondido entre los
   vecinos con sombrero, las 10 diferencias (3 por semilla, modelos chicos), la ficha del verdadero en la planilla.
2. El cambiazo y las barbaridades: cuando el verdadero baja, el doble sube por detrás; el verdadero vuelve y se queda
   abajo; las 10 barbaridades como manchas; los cruces siguientes.
3. Esposar: al doble (se le cae el bigote, escolta), al verdadero (pregunta 2), el sueldo con el doble detenido, la
   huida a pie del doble y el online.

## Preguntas para Cristian
1. **¿Cómo se distingue al doble?** Recomendado: 3 diferencias chicas que se ven de cerca (de una lista de 10, al azar
   por semilla) y la ficha del verdadero en la planilla para comparar. Así hay que acercarse a mirar y leer. La otra
   opción es que sean iguales en todo y se lo descubra solo por lo que dice.
2. **¿Qué pasa si esposan al verdadero?** Recomendado: se ofende ("¿¡Saben quién soy yo!?"), son 3 manchas de golpe y
   se lo suelta enseguida (las esposas se abren solas). Así equivocarse duele pero no termina el caso. La otra opción
   es que el caso se pierda a la primera.
3. **¿El doble y el verdadero se cruzan cada vez que uno baja?** Recomendado: sí, el doble sube por detrás del
   escenario cada vez que el verdadero baja a saludar, así hay que volver a mirar. La otra opción es que el doble suba
   una sola vez y el verdadero se quede abajo hasta que lo lleven de la mano.

## Hecho así
- **Paso 1 (el doble, las diferencias y la ficha):** `--place=double` abre `scenes/levels/plaza_double.tscn`, la misma
  plaza del acto con `PlazaRally.variant = "double"`, y el sorteo de Jugar reparte las protecciones en tercios (plaza,
  mercado y doble, `PlaceDraw.RALLIES`). Rolo Calcado es otro `Politician` con `impostor`, parado al final de la fila
  de atrás del público, con galera y bufanda (`disguise`) que le tapan las diferencias; con E dice que solo vino a
  mirar. Los dos llevan las 10 diferencias (`DoubleTells`, piezas chicas hechas en código, una vez y media más grandes
  de lo normal); el doble tiene 3 al revés, sacadas con la semilla. La planilla (Q) suma la ficha del verdadero, una
  línea por diferencia. El comisario cuenta lo del imitador. Capturas en `/mnt/project-files/doble/paso1-*.png`.
