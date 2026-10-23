# BPD · Protección de un político (propuesta, 23/10)

Noveno tipo de caso, del catálogo ([casos.md](casos.md), punto 9) y la decisión 32. Cristian respondió las 3 preguntas el 23/10
(decisión 103). Los números son **(propuesta)** hasta probarlos jugando.

## La idea
El comisario les da el peor trabajo: cuidar a un político molesto durante un acto. Nadie lo quiere, todos le tiran
cosas y él no ayuda: se baja del escenario a saludar, se saca fotos y se pone justo donde no tiene que estar. El chiste
cooperativo: unos se tiran delante de los huevos y los tomates con el cuerpo, otros buscan entre la gente a los que
tiran y otro lo arrastra de vuelta al escenario de la mano.

## Primera variante: Acto en una plaza (casos.md, 9.1)
El diputado **Pompeyo Lustre** (propuesta de nombre, modelo `npc_politico` que ya existe) da un discurso en la plaza
del centro de la ciudad. Es la que mejor enseña las reglas; las otras variantes cambian una sola cosa.

## Cómo es el caso
1. **El aviso:** en la oficina del comisario, como el allanamiento: "Novatos, el diputado Lustre habla en la plaza.
   Que no le pase nada. Y que no hable de más, si se puede".
2. **La plaza:** la del centro de la ciudad, que ya existe (cuadra 3, 2), con la fuente. Se suma un escenario con
   atril, micrófono y globos, y unos 16 vecinos mirando (los modelos de siempre).
3. **El discurso:** dura 6 minutos (propuesta) y es el reloj del caso. No se pierde por tiempo: cuando termina, termina
   el turno (como el taladro del banco, decisión 102, aunque los casos no tengan tiempo límite por la decisión 66).
4. **Los que tiran:** entre la gente hay 4 que tiran cosas (al azar por semilla). Tiran un huevo o un tomate cada tanto
   en un arco que se ve venir. Son objetos con física: un policía en el medio lo para con el cuerpo (y queda manchado),
   y también se pueden agarrar en el aire si se apunta bien.
5. **Las manchas:** cada huevo o tomate que le pega al político es una mancha en su traje, y él se queja por el
   micrófono. Con 10 manchas se va furioso y el caso se pierde (propuesta).
6. **Encontrarlos:** el que tira tiene las manos sucias y una bolsa del mercado. Se lo ve tirar si alguien mira justo
   (como el cono de visión del banco, al revés). Esposado, se lo escolta al patrullero como a los ladrones; los que
   quedan tiran más seguido.
7. **El político molesto:** cada tanto se baja del escenario a saludar a la gente o a sacarse una foto. Abajo es un
   blanco fácil. Se lo lleva de vuelta de la mano, como a los rehenes del banco, quejándose.
8. **Se gana** si termina el discurso con menos de 10 manchas. Sueldo de 600: 50 menos por mancha y 50 más por cada uno
   que tiraba y quedó detenido. Cuota propia de 400, como la persecución (decisión 91).
9. **El último que tira** (si no lo agarraron) huye en un monopatín cuando termina el discurso: si lo atrapan, suma
   como detenido (persecución embebida, decisión 96). Si no, el caso igual se gana.

## Las 10 variantes (de casos.md)
| # | Variante | Lo que cambia |
|---|---|---|
| 1 | Acto en una plaza | La base. **Primera variante a programar.** |
| 2 | Inauguración de un puente | El puente se desarma de a poco mientras él corta la cinta. |
| 3 | Visita a una escuela | Los chicos le hacen preguntas; las que lo ponen en problemas cuentan como manchas. |
| 4 | Debate en televisión | El sabotaje viene desde el control de cámaras; hay que encontrar al que toca los botones. |
| 5 | Partido de fútbol benéfico | El político juega, mal; los pelotazos de los rivales son los tomates. |
| 6 | Caminata por el mercado | Quiere probar todo y una comida tiene laxante; hay que probar antes que él. |
| 7 | En el aeropuerto | Valijas iguales, y una tiene algo raro. |
| 8 | Fiesta de cumpleaños | El pastel es sospechoso (reusa la torta del laboratorio de pasteles). |
| 9 | Desfile en descapotable | Los 4 van caminando al lado del auto, que no para. |
| 10 | El doble | Hay dos políticos iguales y uno es un impostor. |

## Lo que se reusa
- La plaza de la ciudad (CityLayout.PLAZA) y los vecinos de siempre como público.
- Llevar de la mano a los rehenes del banco (para el político), esposas y escolta del allanamiento (para los que tiran),
  persecución embebida (ChaseCase.begin) y la custodia para el interrogatorio (decisión 93).
- Lo nuevo: el escenario, el huevo y el tomate (objetos con física que se rompen y manchan), las manchas en el traje y
  el político que se baja.

## El orden para hacerlo (un PR chico por paso)
1. El escenario en la plaza y el político dando el discurso (con su reloj y sus quejas).
2. El público y los que tiran: el huevo y el tomate con física, el arco, las manchas.
3. Pararlos con el cuerpo o agarrarlos en el aire; el policía manchado.
4. Encontrar y esposar a los que tiran; escoltarlos al patrullero.
5. El político que se baja y llevarlo de la mano.
6. El final: sueldo, cuota, el del monopatín y el sorteo de Jugar. Después, online.

## Preguntas para Cristian
1. **¿Empezamos por el acto en la plaza** con el diputado Pompeyo Lustre? Recomendado: sí.
2. **¿Se pierde con 10 manchas** (se va furioso), o las manchas solo bajan el sueldo y el caso no se pierde nunca?
   Recomendado: se pierde con 10, así hay algo en juego.
3. **¿El político se baja del escenario** a saludar y a sacarse fotos, y hay que llevarlo de vuelta de la mano?
   Recomendado: sí, es lo que lo hace molesto.

## Respuestas de Cristian (23/10, decisión 103)
1. Sí: se empieza por el acto en la plaza (lo eligió en la tarjeta).
2. Con 10 manchas se va furioso y el caso se pierde.
3. Sí: se baja a saludar y sacarse fotos, y hay que llevarlo de vuelta de la mano.

## Hecho así
