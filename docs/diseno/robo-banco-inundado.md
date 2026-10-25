# BPD · Robo a un banco: La bóveda que se inunda (propuesta, 25/10)

Sexta variante del robo a un banco en vivo ([casos.md](casos.md), 10.6), sobre la base de los ladrones con máscaras
de animales ([robo-banco.md](robo-banco.md), decisión 102), junto a la fiesta de los rehenes
([robo-banco-rehenes.md](robo-banco-rehenes.md), decisión 121), los ladrones abuelos
([robo-banco-abuelos.md](robo-banco-abuelos.md), decisión 122), el ladrón arrepentido
([robo-banco-arrepentido.md](robo-banco-arrepentido.md), decisión 123) y el gerente
([robo-banco-gerente.md](robo-banco-gerente.md), decisión 124). Todos los números son **(propuesta)** hasta probarlos
jugando. La decisión de esta variante es la 125, de las que quedan del hilo A.

## La idea
El pato taladró mal: la mecha pinchó el caño grande que pasa detrás de la bóveda y sale un chorro de agua por el
agujero de la puerta. El banco se va llenando de a poco, y el agua frena a todos: a los policías, a los rehenes y
también a los ladrones. Y frena al taladro, que se moja. El chiste cooperativo: dejar subir el agua frena el robo,
pero también los deja a ustedes caminando como en una pileta y a los rehenes subidos a los mostradores. Hay que
elegir cuándo cerrar el agua, y uno tiene que ir a cerrarla afuera mientras los otros chapotean adentro.

## La historia del comisario
"¡Novatos! ¡Roban el Banco del Barrio y encima rompieron un caño! ¡Lleven las botas de lluvia!"

## Cómo es el caso
1. **El chorro:** cuando llegan, del agujero de la bóveda sale un chorro de agua hacia el pasillo. El agua cubre el
   piso de todo el banco (hall, oficina y pasillo) y sube 0,2 m por minuto hasta 1 m como mucho (5 min). Se ve como
   una superficie azul que sube, y se oye el chorro.
2. **El agua frena a todos:** al que camina en el agua se le baja la velocidad según lo alto que esté: hasta la
   rodilla (0,3 m) va a 0,8, hasta la cintura (0,6 m) a 0,6 y con 1 m de agua a 0,45. Vale para policías, ladrones y
   rehenes. Afuera del banco, nada.
3. **El taladro se moja:** cuando el agua pasa los 0,5 m (el motor del taladro), chisporrotea y va a la mitad de
   velocidad (ver pregunta 1). El pato lo patea y dice "¡Glu, glu!".
4. **Los rehenes en los mostradores:** con el agua a la cintura (0,6 m) los rehenes se suben a los mostradores y a
   los bancos del hall ("¡No sé nadar!") y no se dejan llevar de la mano. Para bajarlos hay dos maneras: bajar el
   agua de nuevo a menos de 0,6 m, o darles un flotador (en el baúl del patrullero hay cuatro, de patito). Con el
   flotador puesto se lo lleva de la mano a velocidad normal, flotando (ver pregunta 3).
5. **La llave de paso:** afuera, en la vereda de atrás junto a la puerta de atrás, hay una rueda roja en un caño.
   Mantener E 8 s la cierra (si giran dos policías a la vez, 4 s). Cerrada, el agua deja de subir. Para que baje hay
   que abrir la puerta de adelante: sale de golpe (una ola que empuja hacia la vereda lo que flota cerca de la
   puerta) y después baja 0,1 m cada 10 s mientras esté abierta (ver pregunta 2).
6. **Las cosas flotan:** las cosas físicas que quedan en el agua flotan y se mueven despacio: las bolsas de plata, las
   medialunas de la fiesta, los conos. El flotador de patito también, si se lo suelta.
7. **La huida:** cuando la bóveda se abre, los ladrones sueltos cargan las bolsas como siempre, pero si el agua está
   alta caminan a la velocidad del agua y tardan más en llegar a la camioneta. Después, la persecución de siempre.
8. **Se gana** con El Oso esposado, como en la base. Sueldo de 700: 100 menos por cada rehén que quede adentro y 50
   menos por cada bolsa que se lleven; +100 si cierran la llave de paso antes de que el agua llegue a 1 m. Cuota de
   400. **Se pierde** si El Oso se escapa.

## Lo que se reusa
Todo el banco del robo base (lote, hall, bóveda, puerta de atrás), la banda con sus conos, el taladro con su `rate`,
los rehenes que se llevan de la mano, el `slow_factor` del policía (el de los retorcijones del mercado), el baúl del
patrullero, la puerta de adelante y la persecución embebida. Lo nuevo: el agua que sube, el chorro, la llave de paso,
la ola de la puerta y los flotadores.

## El orden para hacerlo (un PR chico por paso)
1. El agua: el chorro, el nivel que sube y frena a todos (policías, ladrones y rehenes). El sorteo pasa a sextos
   (fiesta, abuelos, arrepentido, gerente, inundado y base); `--bank=flood` lo fuerza.
2. La llave de paso (uno o dos policías) y el desagote por la puerta de adelante con la ola.
3. El taladro mojado y los rehenes en los mostradores, con los flotadores del patrullero.
4. Las cosas que flotan, la huida con el agua y el caso (radio del comisario, planilla, sueldo y cuota).
5. El online.

## Preguntas para Cristian
1. **¿El agua también frena el taladro?** Recomendado: sí, a la mitad desde los 0,5 m; así cerrar el agua no es
   siempre lo mejor y hay que elegir el momento. La otra opción es que el agua solo moleste (más simple, sin dilema).
2. **¿La llave de paso está afuera atrás (E 8 s, o 4 s entre dos) y el agua baja solo con la puerta de adelante
   abierta, con la ola?** Recomendado: sí, así hacen falta dos lugares a la vez. La otra opción es que el agua baje
   sola al cerrar la llave.
3. **¿Los rehenes se suben a los mostradores con el agua a la cintura y solo bajan con un flotador o con el agua
   baja?** Recomendado: sí, con cuatro flotadores de patito en el baúl del patrullero. La otra opción es que solo
   caminen más lento.

## Hecho así
