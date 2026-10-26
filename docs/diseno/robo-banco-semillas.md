# BPD · Robo a un banco: El banco de semillas (propuesta, 25/10)

Décima variante del robo a un banco en vivo ([casos.md](casos.md), 10.9), sobre la base de los ladrones con máscaras
de animales ([robo-banco.md](robo-banco.md), decisión 102), junto a la fiesta ([robo-banco-rehenes.md](robo-banco-rehenes.md),
121), los abuelos ([robo-banco-abuelos.md](robo-banco-abuelos.md), 122), el arrepentido
([robo-banco-arrepentido.md](robo-banco-arrepentido.md), 123), el gerente ([robo-banco-gerente.md](robo-banco-gerente.md),
124), la bóveda que se inunda ([robo-banco-inundado.md](robo-banco-inundado.md), 125), el robo por el techo
([robo-banco-techo.md](robo-banco-techo.md), 126), el banco del pueblo ([robo-banco-pueblo.md](robo-banco-pueblo.md),
127) y el banco de sangre ([robo-banco-sangre.md](robo-banco-sangre.md), 128). Todos los números son **(propuesta)**
hasta probarlos jugando. La decisión de esta variante es la 129, la última que queda del hilo A.

## La idea
Esta vez roban el Banco de Semillas, donde se guardan semillas raras de plantas que crecen enseguida. La banda de
siempre vino con sombrero de paja y delantal de jardinero, y usa las semillas como arma: cuando ve a un policía tira
un puñado y en 3 s crece una enredadera que tapa el paso. El chiste cooperativo: hay dos tijeras de podar en el
mostrador; uno corta la enredadera mientras el otro sigue al ladrón. Además, los frascos de semillas son de vidrio: si
se caen fuerte se rompen y en ese lugar crece una planta enorme (y esas semillas se pierden).

## La historia del comisario
"¡Novatos! ¡Roban el Banco de Semillas! Son semillas que crecen en un segundo, así que no las rieguen. Y cuidado con
los frascos: son de vidrio y no hay otras iguales."

## Cómo es el caso
1. **El banco de semillas:** el mismo edificio del robo base, con un cartel con una hoja verde ("Banco de Semillas"),
   macetas en el hall y en el mostrador, y la bóveda de siempre con estantes de frascos de colores en vez de plata. Los
   rehenes en el piso (vinieron a dejar semillas de su huerta, con una maceta en la mano).
2. **La banda jardinera:** los cuatro de la banda con sombrero de paja y delantal verde. El Oso es el jefe, con un
   sombrero más grande y una regadera.
3. **La enredadera:** un ladrón que ve a un policía, en vez de solo gritar, tira semillas al piso entre los dos (una
   vez cada 20 s). En 3 s crece una enredadera de 2 m de alto y 3 m de ancho que no deja pasar a nadie (sí a la banda,
   que conoce el camino entre las hojas) durante 30 s, y después se seca sola.
4. **La tijera de podar:** hay dos en el mostrador. Un policía con la tijera mirando la enredadera la corta en 3 s
   (mantiene E); entre dos con tijera, la mitad. Sin tijera no se puede cortar.
5. **Los frascos:** el taladro (el de la base, 8 minutos) abre la bóveda. Adentro hay 8 frascos chicos. La banda carga
   de a uno hacia la camioneta. Un frasco que cae fuerte (contra el piso o una pared, a más de 4 m/s) se rompe y ahí
   crece una planta grande que estorba hasta el final del caso. Un ladrón esposado suelta el frasco (cae despacio: no
   se rompe). Un policía que corre con un frasco en la mano lo puede tirar sin querer.
6. **El teléfono:** atiende El Oso, que habla como jardinero ("Buenas, habla El Oso, del vivero"). Pide lo mismo de
   siempre con sus palabras (donas "de las de semillas de amapola", que le canten el feliz cumpleaños, que alejen el
   patrullero porque "le pisa el pasto"). Igual que en la base: cumplir le frena el taladro 30 s y mentirle lo acelera.
7. **La huida:** la camioneta de siempre pintada de verde, con macetas en el techo. Cuando El Oso sube, arranca la
   persecución de siempre.
8. **Se gana** con El Oso esposado. Sueldo de 700: 100 menos por cada rehén que quede adentro y 50 menos por cada frasco
   que se lleven o que se rompa. +100 si vuelven los 8 frascos sanos a la bóveda. Cuota de 400. **Se pierde** si El Oso
   se escapa en la persecución.

## Lo que se reusa
Todo el banco del robo base: la banda (modelos con máscara, tareas, conos de visión), los rehenes, el taladro, el
teléfono, las esposas y la escolta, la camioneta y la persecución embebida (ChaseCase.begin). También el ruido de las
cosas que caen fuerte del banco del pueblo (BankClerk.FALL_SPEED) para saber cuándo se rompe un frasco, y las bolsas que
se cargan del banco de sangre (BankBlood.load_up) para la banda que carga los frascos. Lo nuevo: el sombrero y el
delantal, la enredadera, la tijera de podar, los frascos que se rompen y la planta que crece.

## El orden para hacerlo (un PR chico por paso)
1. El banco de semillas (cartel, macetas, frascos en la bóveda, rehenes con maceta) y la banda jardinera (sombrero,
   delantal, la regadera de El Oso). El sorteo pasa a décimos (sorteado antes que todos, las semillas 1 a 4 no
   cambian); `--bank=seeds` lo fuerza.
2. La enredadera y la tijera de podar: la banda que tira semillas al ver un policía, la enredadera que crece y tapa el
   paso 30 s, y cortarla con la tijera.
3. Los frascos: la bóveda que abre el taladro, la banda que los carga a la camioneta, los frascos que se rompen si
   caen fuerte y la planta que crece donde se rompen.
4. El caso: radio, teléfono de jardinero, planilla, sueldo, cuota, la camioneta verde y la persecución.
5. El online.

## Preguntas para Cristian
1. **¿La banda tira semillas que hacen crecer una enredadera que tapa el paso 30 s, y se corta con tijera de podar?**
   Recomendado: sí, una vez cada 20 s cuando ve a un policía, y con dos tijeras en el mostrador. Uno corta y el otro
   sigue, que es el chiste cooperativo. La otra opción es que las semillas sean solo lo que roban, sin enredaderas.
2. **¿Los frascos de semillas se rompen si caen fuerte, y donde se rompen crece una planta grande (50 menos)?**
   Recomendado: sí, y +100 si vuelven los 8 sanos. Así hay que llevarlos con cuidado, sin correr. La otra opción es que
   sean como las bolsas de plata de la base: solo cuentan los que se llevan.
3. **¿La huida es la misma persecución, con la camioneta pintada de verde y macetas arriba?** Recomendado: sí, sin
   cosas nuevas en la calle, para no tocar la persecución. La otra opción es que la camioneta tire semillas que hacen
   crecer arbustos en la calle detrás de ella.

## Hecho así

- **Paso 1 (el banco de semillas y la banda jardinera):** un décimo de las semillas, sorteado antes que todos
  (`hash(["bank semillas", semilla]) % 10`), es el banco de semillas. Las semillas 1 a 4 de las pruebas viejas no
  cambian y `--bank=seeds` lo fuerza. El cartel dice "Banco de Semillas", hay seis macetas con un arbusto redondo (dos
  en el mostrador, dos en la entrada y dos en las esquinas del hall) y una hoja verde arriba de la puerta de la bóveda.
  En la bóveda no hay plata: hay 8 frascos de vidrio con tapa de corcho, dos por estante en los dos estantes de abajo
  de cada mueble, cada uno con semillas de otro color. Esperan quietos hasta que alguien los agarra. Cada rehén tiene
  una maceta chiquita en la mano. Los cuatro de la banda llevan sombrero de paja con cinta verde y delantal verde, y El
  Oso un sombrero más grande y una regadera. Capturas en `/mnt/project-files/semillas/paso1-*.png`.
- **Paso 2 (la enredadera y la tijera):** un ladrón jardinero que ve a un policía tira un puñado de semillas a mitad de
  camino (2,5 m como mucho) y dice "¡Semillas mágicas, a crecer!". Ahí crece en 3 s una enredadera de 3 m de ancho y
  2 m de alto, de cara al policía, que no deja pasar a los policías ni lo que tiran, pero sí a la banda. Cada ladrón
  tira una vez cada 20 s. A los 30 s la enredadera se seca, se pone marrón y se cae. En el mostrador hay dos tijeras
  de podar (rojas). Con una en la mano, cada E sobre la enredadera es un tijeretazo y con 4 se corta; entre dos
  policías con tijera se corta en la mitad de tiempo. En vez de mantener E 3 s (como decía el diseño) son tijeretazos,
  que se ve más y no hace falta un "mantener E" nuevo. Con las manos dice "Con las manos no se puede. Hay tijeras de
  podar en el mostrador.". Capturas en `/mnt/project-files/semillas/paso2-*.png`.
