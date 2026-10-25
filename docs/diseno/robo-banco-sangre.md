# BPD · Robo a un banco: El banco de sangre (propuesta, 25/10)

Novena variante del robo a un banco en vivo ([casos.md](casos.md), 10.7), sobre la base de los ladrones con máscaras
de animales ([robo-banco.md](robo-banco.md), decisión 102), junto a la fiesta ([robo-banco-rehenes.md](robo-banco-rehenes.md),
121), los abuelos ([robo-banco-abuelos.md](robo-banco-abuelos.md), 122), el arrepentido
([robo-banco-arrepentido.md](robo-banco-arrepentido.md), 123), el gerente ([robo-banco-gerente.md](robo-banco-gerente.md),
124), la bóveda que se inunda ([robo-banco-inundado.md](robo-banco-inundado.md), 125), el robo por el techo
([robo-banco-techo.md](robo-banco-techo.md), 126) y el banco del pueblo ([robo-banco-pueblo.md](robo-banco-pueblo.md),
127). Todos los números son **(propuesta)** hasta probarlos jugando. La decisión de esta variante es la 128, de las que
quedan del hilo A.

## La idea
Esta noche no roban plata: roban el Banco de Sangre, donde se guardan las donaciones. La banda de siempre vino
disfrazada de vampiros (capa negra, colmillos de plástico y la máscara de animal pintada de blanco) y se toma el
disfraz muy en serio. Cortaron la luz y el banco está a oscuras, con velas. El chiste cooperativo: los vampiros no
soportan la luz. Si un policía les apunta con la linterna se tapan la cara con la capa ("¡La luz no!") y se quedan
quietos, así que uno ilumina mientras el otro los esposa de frente. Además, las bolsas de sangre tienen que volver
frías a la heladera: afuera se calientan y se echan a perder.

## La historia del comisario
"¡Novatos! ¡Roban el Banco de Sangre! Dicen que son vampiros... Son disfraces, ¿no? Lleven las linternas, por las
dudas. Y que no se eche a perder ni una bolsa: es sangre donada."

## Cómo es el caso
1. **El banco de sangre:** el mismo edificio del robo base, con un cartel con una gota roja ("Banco de Sangre") y los
   rehenes en el piso con curitas en el brazo (vinieron a donar). La bóveda es una heladera grande y blanca, cerrada
   con candado. La luz está cortada: el hall y la oficina están a oscuras, con velas en el mostrador y en el piso.
2. **La luz:** la caja de los fusibles está al lado de la puerta de atrás. Un policía la prende con E y vuelve la luz
   a todo el banco por 60 s, hasta que El Conde (El Oso disfrazado) manda a uno de la banda a cortarla otra vez. La
   linterna de cada policía alumbra siempre.
3. **Los vampiros:** los cuatro de la banda, con capa y colmillos, hacen sus tareas de la base. Un vampiro iluminado
   (la linterna a menos de 10 m o la luz prendida del banco) se tapa la cara con la capa durante 4 s: no ve a nadie y
   no se mueve. Con la luz prendida se tapa una sola vez y después se pone unos lentes de sol (ya no le hace nada la
   luz del techo, solo la linterna).
4. **Esposar:** de atrás como siempre; de frente, solo si está tapado. Si no, se rinde o grita como en la base.
5. **Las bolsas de sangre:** el taladro (el de la base, 8 minutos) abre la heladera. Adentro hay 6 bolsas rojas
   chiquitas. La banda carga de a una hacia la camioneta. Una bolsa fuera de la heladera se calienta en 60 s (se pone
   cada vez más oscura) y se echa a perder. Se enfría otra vez si un policía la devuelve a la heladera o la mete en la
   heladerita del patrullero.
6. **El teléfono:** atiende El Conde, con voz de vampiro de película ("Buenas noches..."). Pide cosas de vampiro (que
   apaguen las sirenas, un ataúd con almohadón, jugo de tomate). Igual que en la base: cumplir le frena el taladro 30 s y
   mentirle lo acelera.
7. **La huida:** la camioneta es una carroza negra con un ataúd atrás. Cuando la heladera se abre, El Conde se mete en
   el ataúd con las bolsas que tenga la banda y arranca la persecución de siempre contra la carroza. Al final se abre el
   ataúd y se lo esposa.
8. **Se gana** con El Conde esposado. Sueldo de 700: 100 menos por cada rehén que quede adentro y 50 menos por cada
   bolsa que se lleven o que se eche a perder. +100 si las 6 bolsas vuelven frías a la heladera. Cuota de 400. **Se
   pierde** si El Conde se escapa en la persecución.

## Lo que se reusa
Todo el banco del robo base: la banda (modelos con máscara, tareas, conos de visión), los rehenes, el taladro, el
teléfono, las esposas y la escolta, la camioneta y la persecución embebida (ChaseCase.begin). También la linterna de la
herramienta (Flashlight) y las velas de la cárcel a oscuras ([carcel-corte-de-luz.md](carcel-corte-de-luz.md)). Lo
nuevo: la capa y los colmillos de la banda, la caja de fusibles, la heladera, las bolsas que se calientan y la carroza.

## El orden para hacerlo (un PR chico por paso)
1. El banco de sangre a oscuras (cartel, velas, heladera en lugar de la bóveda, rehenes con curitas) y la banda
   disfrazada (capa, colmillos, El Conde). El sorteo pasa a novenos (sorteado antes que todos, las semillas 1 a 4 no
   cambian); `--bank=blood` lo fuerza.
2. La luz: la linterna y la caja de fusibles. Los vampiros que se tapan la cara, los lentes de sol, esposar de frente
   al tapado y El Conde que manda a cortar la luz.
3. Las bolsas de sangre: la heladera que abre el taladro, las bolsas que se calientan y se echan a perder, y
   devolverlas a la heladera o a la heladerita del patrullero.
4. El caso: radio, teléfono de vampiro, planilla, sueldo, cuota, la carroza con el ataúd y la persecución.
5. El online.

## Preguntas para Cristian
1. **¿Los vampiros se tapan la cara con la capa y se quedan quietos 4 s cuando les apuntan con la linterna?**
   Recomendado: sí, y de frente solo se esposa al que está tapado. Uno ilumina y el otro esposa, que es el chiste
   cooperativo. La otra opción es que el disfraz sea solo de mirar y la banda juegue como en la base.
2. **¿Las bolsas de sangre se echan a perder si pasan 60 s fuera de la heladera?** Recomendado: sí, 50 menos por cada
   bolsa perdida y +100 si vuelven las 6 frías. Así recuperar las bolsas tiene apuro. La otra opción es que sean como
   las bolsas de plata de la base: solo cuentan las que se llevan.
3. **¿La huida es en una carroza negra con El Conde escondido en un ataúd?** Recomendado: sí, la misma persecución de
   la base con otro modelo, y al final se abre el ataúd. La otra opción es la camioneta de siempre.

## Hecho así

- **Paso 1 (el banco a oscuras y los disfraces):** un noveno de las semillas, sorteado antes que todos
  (`hash(["bank sangre", semilla]) % 9`), es el banco de sangre. Las semillas 1 a 4 de las pruebas viejas no cambian y
  `--bank=blood` lo fuerza. Es de noche (luna azul y poca luz) y las lámparas del techo están apagadas. Hay diez velas
  prendidas que titilan: cuatro en el mostrador, dos junto a los rehenes, dos en la entrada y dos en el pasillo. El
  cartel dice "Banco de Sangre". La puerta redonda de la bóveda es blanca, con una gota roja arriba y el cartel
  "HELADERA". Adentro, los estantes tienen bolsas rojas en vez de plata. Los rehenes tienen una curita en el brazo y los
  cuatro de la banda llevan capa negra forrada de rojo, cuello alto y dos colmillos de plástico debajo de la máscara.
  La máscara no está pintada de blanco: con la capa y los colmillos ya se entiende. Capturas en
  `/mnt/project-files/sangre/paso1-*.png`.
