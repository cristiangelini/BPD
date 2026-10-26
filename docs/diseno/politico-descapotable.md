# BPD · Protección del político: El desfile en descapotable (propuesta, 26/10)

Variante de la protección de un político ([casos.md](casos.md), 9.9), sobre la base del acto en la plaza
([proteccion-politico.md](proteccion-politico.md), decisión 103). Todos los números son **(propuesta)** hasta
probarlos jugando. La decisión de esta variante es la 222 (de las 220 a 229).

## La idea
El diputado **Pompeyo Lustre** no quiere atril: quiere desfilar. Va parado en el asiento de atrás de un descapotable
rojo, saludando, a paso de hombre, una vuelta de cuatro cuadras que sale de la plaza y vuelve a la plaza. Los vecinos
lo esperan en las veredas, y entre ellos los cuatro de siempre con huevos y tomates. Los policías van caminando al lado
del auto, uno en cada esquina, haciendo de escudo. El chiste cooperativo: el auto no para, así que hay que moverse con
él, taparle los costados según de qué vereda viene el tiro, y bajar del auto a los fanáticos que se suben a abrazarlo.

## La historia del comisario
"Novatos, el diputado Lustre hace su desfile en descapotable. Cuatro cuadras, a paso de tortuga. Ustedes van al lado,
caminando. Si llega limpio a la plaza, nos aumentan el presupuesto. Si llega con un tomate en la cara, nos cierran."

## Cómo es el caso
1. **El recorrido:** sale de la plaza y da una vuelta de cuatro cuadras por las calles de la ciudad viva, de unos 400 m,
   y vuelve al escenario de la plaza. El tránsito de la ciudad se corta en esas calles mientras dura (los autos esperan
   en las esquinas). El auto lo maneja un chofer que no se baja nunca.
2. **El reloj:** el desfile dura 6 minutos, como el discurso de la base: el auto avanza solo a lo largo del recorrido a
   1,1 m/s (unos 4 km/h, se puede acompañar caminando) y no para por nada. Una barra arriba muestra cuánto falta. Mientras
   tanto el diputado saluda y dice sus frases de desfile.
3. **Las veredas:** 24 vecinos repartidos en las veredas del recorrido, por tramos. Cuatro son los que tiran, con la
   bolsa de mercado de la base (y tres inocentes con bolsa de compras igual). Tiran cuando el auto pasa cerca de ellos
   (a menos de 12 m), así que los tiros vienen de un costado o del otro según el tramo.
4. **Escudo:** un huevo o un tomate que le pega a un policía en el camino no le llega al diputado (eso ya pasa con la
   física de la base). Ir al lado del auto, del lado de la vereda que tira, es la forma de cuidarlo.
5. **Los abrazadores:** lo que pasa con los fanáticos que se suben al auto sale de la pregunta 2.
6. **Esposar:** como en la base: los que tiran se esposan y con E se los lleva al patrullero, que espera en la plaza.
   Mientras tanto el auto sigue: hay que alcanzarlo.
7. **Se gana** si el auto vuelve a la plaza con menos de 10 manchas en el diputado. Sueldo de 600: 50 menos por mancha y
   50 más por cada uno que tiraba detenido. Cuota de 400, como la plaza. Al final, el último que tira y sigue suelto
   huye en el monopatín, como en la base.

## Lo que se reusa
- El caso del acto: `PoliticianSpeech` como reloj (sus 6 minutos mueven el auto), las manchas (`Politician.stain`), los
  vecinos y los que tiran (`RallyFan`, `RallyThrowable`), esposas, escolta al patrullero, el monopatín y la
  persecución embebida, la planilla y el sueldo.
- Las calles y los autos de la ciudad viva (`CityLayout`, `CityCar` para la forma de seguir un camino).
- Lo nuevo: el descapotable con el chofer, el recorrido, los vecinos por tramos en las veredas, el diputado parado en el
  auto y los abrazadores.

## El orden para hacerlo (un PR chico por paso)
1. El desfile: el sorteo de las protecciones pasa a quintos (`--place=convertible`), el descapotable con el chofer y el
   diputado parado saludando, el recorrido de cuatro cuadras, el tránsito cortado y el reloj que mueve el auto.
2. Las veredas: los vecinos por tramos, los que tiran cuando pasa el auto, y los abrazadores.
3. El caso: la historia del comisario, la planilla, el sueldo, la huida en monopatín y el online.

## Preguntas para Cristian
1. **¿El auto para si algo se le cruza?** Recomendado: no, el desfile no para por nada (un policía delante se corre o
   lo empuja de costado), así el reloj es siempre de 6 minutos y hay que caminar con él. La otra opción es que frene
   ante un policía delante, para poder "frenar el desfile" a propósito mientras se esposa a alguien.
2. **¿Qué hacen los fanáticos que se suben al auto?** Recomendado: cada 50 s uno corre al auto y se sube a abrazarlo; mientras
   está arriba, cada 5 s es una mancha de imagen (le arruga el traje). Con E se lo baja y vuelve a la vereda. La otra
   opción es sin abrazadores: solo huevos y tomates.
3. **¿Desde dónde tiran?** Recomendado: solo desde las veredas, a la altura de la gente, como en la base. La otra
   opción es sumar tiradores en los balcones, que tiran desde arriba y no se pueden esposar hasta bajar a buscarlos.
