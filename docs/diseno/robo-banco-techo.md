# BPD · Robo a un banco: Robo por el techo (propuesta, 25/10)

Séptima variante del robo a un banco en vivo ([casos.md](casos.md), 10.4), sobre la base de los ladrones con máscaras
de animales ([robo-banco.md](robo-banco.md), decisión 102), junto a la fiesta ([robo-banco-rehenes.md](robo-banco-rehenes.md),
121), los abuelos ([robo-banco-abuelos.md](robo-banco-abuelos.md), 122), el arrepentido
([robo-banco-arrepentido.md](robo-banco-arrepentido.md), 123), el gerente ([robo-banco-gerente.md](robo-banco-gerente.md),
124) y la bóveda que se inunda ([robo-banco-inundado.md](robo-banco-inundado.md), 125). Todos los números son
**(propuesta)** hasta probarlos jugando. La decisión de esta variante es la 126, de las que quedan del hilo A.

## La idea
Esta vez la banda no escapa en la camioneta: se va por el techo. El sobrino de El Oso, un chico con gorra, maneja
desde la vereda de enfrente un helicóptero de juguete enorme (a control remoto) que aterriza en el techo del banco.
Cuando la bóveda se abre, los ladrones suben las bolsas por una trampilla y el helicóptero se las lleva de a una.
Al final se lleva a El Oso, colgado de una soga, volando bajito y despacio sobre la calle. El chiste cooperativo: hay
que subir al techo antes, por la escalera de incendio de afuera, mientras los otros siguen con los rehenes y el
teléfono, y alguien tiene que darse cuenta de que el chico que juega en la vereda de enfrente es el sobrino.

## La historia del comisario
"¡Novatos! ¡Roban el Banco del Barrio! Un vecino dice que vio un helicóptero... de juguete. Miren para arriba."

## Cómo es el caso
1. **El techo:** en el pasillo de la bóveda hay una trampilla en el techo con una escalera (la de los ladrones, por
   adentro). Afuera, en la pared del este, una escalera de incendio sube hasta el techo. En el techo hay una cruz
   pintada donde aterriza el helicóptero.
2. **El helicóptero de juguete:** grande como una heladera, amarillo, con las hélices que zumban. Espera en el techo
   desde el principio. Si un policía lo agarra (pesa 40 kg: uno solo lo arrastra, entre dos se lleva) y lo baja a la calle o lo mete
   en el baúl del patrullero, la banda ya no tiene cómo irse por arriba: la huida es la de siempre, en la camioneta
   (ver pregunta 1).
3. **El sobrino:** sentado en un banco de la vereda de enfrente, con el control remoto en la mano y una gorra al revés,
   haciéndose el que juega ("¡Mire mi helicóptero, oficial!"). Si ve a un policía en el techo del banco, hace despegar
   el helicóptero y lo tiene volando en círculos 20 s, fuera de alcance. Esposarlo deja al helicóptero sin piloto: cae
   donde esté (ver pregunta 3).
4. **La huida por arriba:** cuando la bóveda se abre, los ladrones sueltos suben con las bolsas al techo. El
   helicóptero se lleva una bolsa por viaje (cada viaje tarda 20 s) hasta la vereda del sobrino, donde espera un carrito de supermercado. Cuando se acabaron
   las bolsas, se lleva a El Oso colgado de la soga: arranca la persecución, pero contra un helicóptero que vuela
   bajito sobre la calle. Si el patrullero pasa por debajo, el policía que va de acompañante saca el brazo por la
   ventanilla y con E agarra la soga: El Oso cae al asiento de atrás, esposado (ver pregunta 2). Si el sobrino ya estaba esposado o el helicóptero ya no estaba, la huida es la de siempre.
5. **Se gana** con El Oso esposado, como en la base. Sueldo de 700: 100 menos por cada rehén que quede adentro y 50
   menos por cada bolsa que se lleve el helicóptero; +100 si esposan al sobrino. Cuota de 400. **Se pierde** si El Oso
   se escapa colgado del helicóptero.

## Lo que se reusa
Todo el banco del robo base, la banda con sus conos, el taladro, el teléfono, las esposas y la escolta (OwnerEscort),
las cosas que se agarran entre dos (como la caja fuerte), el baúl del patrullero, las escaleras de PlaceBuilder y la
persecución embebida (ChaseCase.begin). Lo nuevo: el techo con su trampilla y la escalera de incendio, el helicóptero
de juguete, el sobrino con el control y la persecución en el aire.

## El orden para hacerlo (un PR chico por paso)
1. El techo (trampilla, escalera de incendio y la cruz), el helicóptero en el techo y el sobrino en la vereda de
   enfrente. El sorteo pasa a séptimos; `--bank=roof` lo fuerza.
2. El helicóptero: agarrarlo y llevárselo, y el sobrino que lo hace despegar cuando ve a un policía en el techo.
3. Esposar al sobrino: el helicóptero cae.
4. La huida por arriba (las bolsas de a una y El Oso colgado), la persecución contra el helicóptero y el caso (radio,
   planilla, sueldo y cuota).
5. El online.

## Preguntas para Cristian
1. **¿Agarrar el helicóptero y bajarlo del techo (40 kg, entre dos) deja a la banda sin huida por arriba?**
   Recomendado: sí, así subir temprano tiene premio. La otra opción es que el helicóptero no se pueda agarrar y solo
   sirva esposar al sobrino.
2. **¿En la persecución se lo agarra desde la ventanilla del patrullero, pasando por debajo?** Recomendado: sí, el
   acompañante con E agarra la soga; obliga a manejar y agarrar a la vez. La otra opción es tirarle cosas hasta que
   caiga.
3. **¿El sobrino con el control está en la vereda de enfrente haciéndose el que juega, y esposarlo hace caer el
   helicóptero?** Recomendado:
   sí, con +100. La otra opción es que el sobrino no exista y el helicóptero vuele solo.

## Hecho así

- **Paso 1 (el techo, el helicóptero y el sobrino):** un séptimo de las semillas, sorteado antes que todos
  (`hash(["bank azotea", semilla]) % 7`), es el robo por el techo; las semillas 1 a 4 de las pruebas viejas no cambian y
  `--bank=roof` lo fuerza. Afuera de la pared del este una escalera de incendio sube hacia atrás hasta un descanso a la
  altura del techo, y de ahí se pasa al techo. En el pasillo de la bóveda hay una trampilla oscura en el techo con su
  escalera de mano contra la pared de la oficina (solo se ve: los policías suben por afuera), y arriba su tapa. En el
  techo, la cruz pintada en un círculo blanco con el helicóptero de juguete (`ToyHelicopter`) esperando, las hélices
  girando. Pesa 40 kg y no 25: con 25 un policía solo ya lo carga, y la idea es que haga falta llevarlo entre dos. El
  sobrino (`BankNephew`, más chico que los grandes) está sentado en un banco de la vereda de enfrente con el control
  en la mano, mirando al banco; con E dice sus frases de inocente ("¡Mire mi helicóptero, oficial!"). Capturas en
  `/mnt/project-files/techo/paso1-*.png`.
- **Paso 2 (agarrar el helicóptero y que despegue):** cuando el sobrino ve a un policía arriba del techo, hace
  despegar el helicóptero ("¡Despega, despega! Digo... ¡qué lindo vuela!"): se les escapa de las manos a los que lo
  tenían, sube 5 m sobre la cruz y da vueltas de 6 m de radio durante 20 s, y después baja a la cruz. Para que se pueda
  agarrar, el control necesita 40 s de descanso después de cada vuelo (`NEPHEW_REST`): ese es el momento de llevárselo
  entre dos por la escalera de incendio, o de tirarlo a la calle. Fuera del techo (en la calle, en el baúl) la banda ya
  no tiene helicóptero, y la barra lo avisa una vez. La barra también avisa cuando despega: "Alguien lo maneja desde
  abajo", la pista para buscar al sobrino. Captura en `/mnt/project-files/techo/paso2-vuela.png`.
- **Paso 3 (esposar al sobrino):** las esposas lo atrapan para siempre (`BankNephew.caught`): suelta el control y
  delata al tío ("¡Fue idea de mi tío! ¡Yo solo quería jugar!"), y la barra avisa "¡Era el sobrino de El Oso!". El
  helicóptero se queda sin piloto (`ToyHelicopter.crash`): si estaba volando cae donde esté, y en el suelo queda
  volcado con la hélice doblada; ya no vuela más y la banda no tiene huida por el techo (`roof_way_out`). El +100 va
  en la planilla del paso 4. Capturas en `/mnt/project-files/techo/paso3-*.png`.
