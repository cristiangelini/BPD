# BPD · Protección del político: Visita a una escuela (propuesta, 26/10)

Variante 9.3 de la protección de un político ([casos.md](casos.md)), sobre la base del acto en la plaza
([proteccion-politico.md](proteccion-politico.md), decisión 103) y la caminata por el mercado
([politico-mercado.md](politico-mercado.md)). Todos los números son **(propuesta)** hasta probarlos jugando. Las
decisiones de esta variante usan los números 210 a 219.

## La idea
El diputado **Pompeyo Lustre** visita la escuela primaria "Los Girasoles" para la foto con los chicos. Da una charla
en el aula y después contesta preguntas. Su rival le pagó al conserje para que reparta a los chicos tarjetas con
preguntas que lo hunden ("¿Es verdad que usted se queda con la plata de los recreos?"), y los chicos no saben lo que
están leyendo. El chiste cooperativo: unos le sacan las tarjetas a los chicos sin hacerlos llorar, otros vigilan al
conserje en el recreo y otro distrae al diputado para que no le dé la palabra al chico equivocado.

## La historia del comisario
"Novatos, el diputado Lustre visita la escuela Los Girasoles. Charla, preguntas de los chicos y foto. Me dicen que hay
preguntas preparadas. Ningún chico lo deja en ridículo, ¿entendido? Y nada de esposar maestras."

## Cómo es el caso
1. **La escuela:** un edificio nuevo en la ciudad, en una cuadra libre (se elige en el paso 1), de una planta: la
   entrada con el busto del fundador, un pasillo con percheros y mochilas, el aula (20 bancos chicos en 4 filas, el
   pizarrón, el escritorio de la maestra y una caja de caramelos) y el patio de atrás con tobogán, arenero y el cuarto
   del conserje con su carrito de limpieza.
2. **La gente:** 20 alumnos (un modelo nuevo, `npc_alumno`, chico y con guardapolvo, con 4 caras y 4 colores de
   mochila), la maestra (`npc_maestra`) y el conserje (`npc_conserje`, con mameluco y escoba).
3. **La visita:** el diputado llega cuando el primer policía está a menos de 25 m, como en la plaza. Son 3 partes y
   el reloj del caso: **charla** en el aula (2 minutos, frases suyas en el pizarrón), **recreo** en el patio (2
   minutos, juega mal con los chicos y se saca fotos) y **preguntas** en el aula (3 minutos). Al final, la foto
   grupal en la entrada. Unos 7 minutos en total.
4. **Las tarjetas:** cada alumno tiene una tarjeta en la mano con su pregunta. Las comunes son inocentes ("¿Usted
   tiene perro?", "¿Cuál es su dinosaurio favorito?"); las **trampa** las repartió el conserje. Al empezar hay 5
   trampa entre los 20 (por semilla). Las dos se ven iguales de lejos; a menos de 2 m el policía lee lo que dice.
5. **Las preguntas:** en la parte de preguntas, cada 15 s el diputado dice "¿A ver, quién pregunta?" y le da la
   palabra a uno de los que tienen la mano levantada, al azar. Los que tienen trampa la levantan siempre y la mueven
   con ganas; los demás, 1 de cada 3. El chico lee su tarjeta en voz alta (cartel arriba). Si es trampa, el diputado
   tartamudea, se pone colorado y es una **metida de pata**. Con 8 se va avergonzado y el caso se pierde, como las
   10 manchas de la plaza (decisión 103).
6. **Sacarle la tarjeta:** un policía agarra la tarjeta con las manos, como cualquier objeto, y el chico baja la
   mano. Si estaba sentado y era inocente, se enoja ("¡Era mía!") y llora 10 s; con un caramelo de la caja de la
   maestra se calma. La tarjeta se puede romper (clic con ella en la mano) o devolver.
7. **Darle la palabra a otro:** un policía parado a menos de 1,5 m del diputado puede señalar (clic sin nada en la
   mano) a un chico con la mano levantada, y el diputado le da la palabra a ese (una vez cada 15 s).
8. **El conserje:** el rival le pagó. En el recreo camina por el patio y le da una tarjeta trampa nueva a un chico
   cada 20 s (le cambia la que tenía); en el aula entra a "barrer" y hace lo mismo cada 45 s. Pistas: el bolsillo del
   mameluco con un mazo de tarjetas que asoma, tinta violeta en los dedos (otras 2 personas tienen tiza o
   témpera, por semilla) y un sobre con plata en su cuarto, en el carrito de limpieza (cajones que se abren con las
   manos, decisión 76). Esposado, ya no reparte, y se lo escolta al patrullero como a los que tiraban huevos.
9. **Se gana** cuando el diputado se saca la foto grupal con menos de 8 metidas de pata. Sueldo de 600: 50 menos por
   metida de pata, 25 menos por cada chico que lloró y 100 más si el conserje quedó detenido. Cuota propia de 400,
   como la plaza (decisión 103).
10. **El final:** si el conserje sigue suelto cuando se saca la foto, huye en su lustradora de pisos por la vereda,
    que deja el piso resbaloso (persecución embebida, decisión 96). Atrapado, cuenta como detenido.

## Lo que se reusa
- El diputado, su modelo, llevarlo de la mano y sus quejas (decisión 103); el reloj del caso de la plaza; esposas,
  escolta al patrullero y la persecución embebida (ChaseCase.begin); los cajones con las manos; agarrar objetos con
  las manos; el piso resbaloso del heladero para la lustradora.
- Lo nuevo: la escuela, los alumnos, la maestra, el conserje, las tarjetas, las manos levantadas, señalar a un chico,
  el llanto y los caramelos.

## El orden para hacerlo (un PR chico por paso)
1. La escuela en la ciudad: el edificio, el aula con bancos, el patio, los alumnos sentados, la maestra y el conserje
   (`--place=school_visit`).
2. La visita: el diputado llega, charla, recreo en el patio y vuelta al aula (el reloj del caso).
3. Las tarjetas y las preguntas: manos levantadas, darle la palabra a uno, leer en voz alta y las metidas de pata.
4. Sacarle la tarjeta, romperla, el llanto y el caramelo; señalar a otro chico.
5. El conserje: reparte trampas en el recreo y en el aula, sus pistas, esposarlo y escoltarlo.
6. El final: sueldo, cuota, la foto, la lustradora y el sorteo de Jugar (los actos del político en tercios). Después,
   online.

## Preguntas para Cristian
1. **¿Se pierde con 8 metidas de pata** (se va avergonzado)? Recomendado: sí, como las 10 manchas de la plaza, así hay
   algo en juego. La otra opción es que solo bajen el sueldo.
2. **¿Se le saca la tarjeta al chico con las manos**, y si era inocente llora hasta que le dan un caramelo?
   Recomendado: sí, así sacarle la tarjeta a todos no sirve. La otra opción es que sacar tarjetas no cueste nada.
3. **¿El que reparte las trampas es el conserje**, que en el recreo y al barrer cambia tarjetas, y si queda suelto
   huye en la lustradora? Recomendado: sí. La otra opción es que las trampas estén desde el principio y no haya
   culpable.
