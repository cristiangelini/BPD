# BPD · Robo a un banco en vivo (propuesta, 22/10)

Octavo tipo de caso, del catálogo ([casos.md](casos.md), punto 10) y la decisión 32 ("llegan cuando el robo está
pasando"). Espera las respuestas de Cristian (al final). Los números son **(propuesta)** hasta probarlos jugando.

## La idea
Suena la radio: están robando el banco del barrio ahora mismo. Los cuatro llegan en el patrullero con el robo en
marcha: los ladrones adentro, los rehenes en el piso y un taladro que va abriendo la bóveda. Hay un reloj que corre
(el taladro), pero no hay tiempo límite del turno: cuando la bóveda se abre, los ladrones cargan las bolsas y huyen, y
el caso sigue como persecución. El chiste cooperativo: uno habla por teléfono con el jefe de la banda para ganar
tiempo, mientras los otros entran por atrás, sacan a los rehenes y esposan a los ladrones de a uno.

## Primera variante: Ladrones con máscaras de animales (casos.md, 10.1)
Cuatro ladrones con máscaras de animales (conejo, chancho, pato y oso; el oso es el jefe, **"El Oso"**, propuesta de
nombre). Cada uno tiene una tarea a la vista y un carácter: el conejo vigila la puerta y se asusta de todo, el chancho
cuida a los rehenes y se distrae comiendo, el pato maneja el taladro y no escucha nada, y El Oso atiende el teléfono.
Es la que mejor enseña las reglas; las otras variantes cambian una sola cosa.

## Cómo es el caso
1. **El aviso:** el comisario lo da por radio, no en su oficina (es en vivo): "¡Novatos! ¡Están robando el banco de la
   esquina! ¡Vayan ya!". Empieza con los cuatro en la comisaría y el patrullero en la puerta, como la persecución.
2. **El banco:** un lote nuevo de la ciudad. Hall con mostradores y 8 rehenes en el piso, la oficina del gerente, el
   pasillo a la bóveda (con el taladro), la puerta de atrás (con llave) y una ventilación en el techo. Afuera, la
   camioneta de la banda en la vereda.
3. **El perímetro:** al llegar, poner los conos y la barrera (los del control de tránsito) alrededor de la camioneta.
   Si la camioneta queda encerrada, la huida es a pie y más lenta.
4. **Negociar:** el teléfono del patrullero llama al banco. El que atiende habla con El Oso, que pide cosas absurdas
   (una pizza de ananá, un helicóptero de juguete, que alguien le cante el feliz cumpleaños). Cada pedido que cumplen
   frena el taladro 30 s y suelta un rehén. Mentirle (prometer y no cumplir) acelera el taladro.
5. **Entrar:** por la puerta de atrás (la llave está en el auto del gerente, que espera afuera en pijama) o por la
   ventilación (un policía levanta a otro). Adentro, cada ladrón mira hacia su tarea con un cono de visión, como el
   guardia de la fuga. Si ve a un policía, grita y los otros se ponen nerviosos: el taladro va más rápido.
6. **Esposar:** a un ladrón que no te ve se lo esposa por detrás (las esposas de siempre). Al esposado se lo escolta
   al patrullero, como al dueño del allanamiento. El conejo, si te ve, se rinde solo; el chancho suelta la comida y
   corre.
7. **Los rehenes:** se los saca de a uno, agarrándolos de la mano hasta la puerta. Si un ladrón ve que se llevan un
   rehén, sube el taladro.
8. **El taladro:** tarda 8 minutos en abrir la bóveda (propuesta), se ve en una barra arriba. Cuando la abre, los
   ladrones que queden sueltos cargan las bolsas y huyen en la camioneta (o a pie si está encerrada): arranca la
   persecución en medio del caso (decisión 96).
9. **Se gana** con El Oso esposado (adentro o al final de la persecución). Sueldo de 700: 100 menos por cada rehén que
   quede adentro y 50 menos por cada bolsa de plata que se lleven. Cuota propia, como la persecución (decisión 91).
   El Oso detenido va al interrogatorio del turno siguiente (decisión 93).
10. **Se pierde** si El Oso se escapa en la persecución.

## Las 10 variantes (de casos.md)
| # | Variante | Lo que cambia |
|---|---|---|
| 1 | Ladrones con máscaras de animales | La base. **Primera variante a programar.** |
| 2 | Rehenes que no quieren irse | Los rehenes se resisten y vuelven a sentarse si no los acompañan hasta afuera. |
| 3 | El banco del pueblo | Banco chico, un solo empleado dormido y un solo ladrón muy nervioso. |
| 4 | Robo por el techo | Los ladrones se van por el techo con un helicóptero de juguete; hay que subir antes. |
| 5 | Ladrones abuelos | Lentos pero astutos; reusa los modelos de abuelos y el andador. |
| 6 | La bóveda que se inunda | El agua sube y frena a todos (también a los ladrones). |
| 7 | Robo en el banco de sangre | Las bolsas son de sangre; los ladrones son vampiros de disfraz. |
| 8 | El ladrón arrepentido | Uno quiere devolver todo y ayuda desde adentro si lo encuentran primero. |
| 9 | Banco de semillas | Las semillas robadas crecen enseguida y llenan el banco de plantas. |
| 10 | El ladrón es el gerente | El gerente en pijama de afuera es el jefe; hay que darse cuenta antes de que se vaya. |

## Lo que se reusa
- Lote nuevo de la ciudad (CityLayout), como la capilla.
- Conos y barrera del control de tránsito; cono de visión y sospecha del guardia de la fuga; esposas y escolta del
  allanamiento; persecución embebida (ChaseCase.begin) con la camioneta; custodia e interrogatorio (decisión 93).
- El teléfono es nuevo: se habla con la voz (o con frases en pantalla si no hay micrófono).

## El orden para hacerlo (un PR chico por paso)
1. El banco (lote, hall, oficina, bóveda, puerta de atrás, ventilación) y la camioneta afuera.
2. Los ladrones (4 modelos con máscara, sus tareas y conos de visión) y los rehenes en el piso.
3. El taladro y su barra; los gritos que lo aceleran.
4. Esposar y escoltar ladrones; sacar rehenes de la mano.
5. El teléfono y los pedidos de El Oso.
6. El perímetro con conos, la huida (persecución) y el final: sueldo, cuota, custodia y sorteo de Jugar.

## Preguntas para Cristian
1. **¿Empezamos por los ladrones con máscaras de animales** (El Oso, conejo, chancho y pato)? Recomendado: sí.
2. **El teléfono con El Oso:** ¿pedidos absurdos que se cumplen para ganar tiempo (recomendado), o solo hablar por la
   voz sin reglas?
3. **El taladro de 8 minutos:** ¿está bien que el robo tenga ese reloj (recomendado), aunque los otros casos no
   tengan tiempo límite (decisión 66)? Al terminar no se pierde: arranca la persecución.
