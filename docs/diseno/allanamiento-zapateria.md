# BPD · El allanamiento de la zapatería (7/11)

Un lugar nuevo para allanar: la zapatería "El Cordón Suelto", un local de una planta con depósito atrás, en la cuadra
(-1, 3), lado norte (libre en todas las ramas al 7/11). Sigue la idea de lugar + historia (decisión 79): una denuncia
anónima, 3 sospechas en la planilla y una sola historia verdadera, sorteada con la semilla. Decisiones 540 a 549.
Todos los números son **(propuesta)** hasta probarlos jugando.

## La idea
Don Suela tiene la zapatería más vieja del barrio y nunca vende un par, pero todas las noches entra y sale un camión
del depósito. Los policías llegan con la orden del juez a un local lleno de torres de cajas de zapatos hasta el techo,
espejos, bancos de probar y un olor a cuero y a pie. El chiste es buscar evidencia donde todo se cae con mirarlo, entre
mil cajas iguales, mientras Don Suela insiste en medirle el pie a cada policía.

## El lugar
- **Un local de 16 x 12 m:** el salón con la vidriera, los bancos de probar, el espejo grande y el mostrador (la caja
  y el timbre); el pasillo de las torres de cajas; el depósito del fondo (cerrado con llave: la llave cuelga del cordón
  que Don Suela lleva al cuello, o se usa el ariete), el taller de arreglos con la máquina de coser suelas y el patio
  de carga.
- **Lo frágil:** las torres de cajas (cada caja que se cae suma 2 a la denuncia; una torre empujada fuerte se viene
  abajo entera) y el espejo grande (roto suma 10, y queda un espejo menos donde mirarse).
- **Los zapatos con resorte de la vidriera:** un policía que se los pone (E) salta el doble de alto durante 30 s y no
  puede correr. Sirven para llegar a lo alto de las torres.
- **Escondites:** unos 12, 6 para cosas pesadas. Por ejemplo: debajo del mostrador, detrás del espejo, dentro de una
  caja de la torre del pasillo, debajo de un banco de probar, en el armario del taller, debajo de la máquina de coser,
  en el baúl de hormas, en la pila de cueros, en el tacho del patio, en el zapato gigante de la vidriera, en el estante
  de las botas de goma y en la caja registradora.

## Don Suela y Lustrín
- **Don Suela:** flaco, larguísimo, con anteojos en la punta de la nariz, una cinta de medir colgada al cuello y un
  calzador en la mano que usa como bastón. Recorre el salón y el pasillo silbando.
- **La denuncia, "¡Me pisaron el cuero!":** como Don Florencio, el doctor Molina y Don Muzza: 15 si lo empujan, 5 por
  puerta rota, 5 por pregunta, y llama al abogado en 100. Además suma 2 por cada caja que ve caer, 10 por el espejo
  roto y 5 si ve a un policía caminar con los zapatos de resorte. Con R suelta 2 cosas por caso y después se ofende.
- **Su distracción, "¿Qué número calza?":** si un policía se sienta en un banco de probar y toca el timbre (E), Don
  Suela se arrodilla delante de él a medirle el pie durante 20 s, de espaldas al resto del local (no ve nada). Se
  puede hacer una vez cada 45 s. Mientras, ese policía no se puede levantar.
- **El chismoso, Lustrín:** el lustrabotas que tiene su cajón en la vereda. Solo habla con el policía que se queda
  quieto 5 s en su cajón para que le lustre las botas. Entonces le cuenta dónde vio a Don Suela esconder algo. Una vez
  por caso.

## Las historias
Cada una tiene una evidencia principal (sin ella no hay caso), 2 extras, un tipo de pista propio y algo que cambia en la
zapatería. La denuncia anónima es siempre vaga: "Don Suela no vende un zapato, pero todas las noches sale un camión".

| Historia | Evidencia principal | Extras | Pista propia | Qué cambia |
|---|---|---|---|---|
| **Los relojes en las botas** | Las botas de goma llenas de relojes robados (6 kg, 1000) | La lupa de relojero (0,2 kg, 300), la lista de compradores (0,1 kg, 200) | Una bota del estante hace tic-tac | El tic-tac de la bota escondida se oye a menos de 3 m |
| **Las zapatillas truchas** | El sello para poner logos falsos (8 kg, 1000) | La bolsa de logos de goma (1 kg, 300), la factura "Zapatillas Voladoras" (0,1 kg, 200) | Una zapatilla de la vidriera tiene el logo al revés | Las zapatillas del salón están mal pegadas: si se las patea, se despegan las suelas y saltan por el aire |
| **Los resortes robados** | El cajón de resortes de la fábrica de colchones (12 kg, 1000) | La pinza de resortes (1 kg, 300), el remito falso (0,1 kg, 200) | El banco de probar rebota cuando alguien se sienta | Hay zapatos de resorte en todos los estantes, no solo en la vidriera |
| **El zapato gigante** | La caja fuerte portátil del banco, adentro del zapato gigante de la vidriera (7 kg, 1000) | El estetoscopio (0,5 kg, 300), el plano del banco (0,1 kg, 200) | Le salen cordones nuevos por la lengüeta, aunque nadie lo atendió | Al zapato gigante se lo puede desatar (E): se abre la lengüeta y un policía se mete por el tobillo |
| **Las llaves del barrio** | El llavero con copias de las llaves de todas las casas del barrio (2 kg, 1000) | La máquina de copiar llaves (5 kg, 300), el cuaderno de direcciones (0,1 kg, 200) | Las plantillas del taller tienen forma de llave | La máquina de medir pies del mostrador atrapa el pie del policía que la usa durante 3 s |
| **Los zapatos de cristal** | Los zapatos de cristal robados del concurso "Reina del barrio" (2 kg, 1000) | La corona de cartón (0,5 kg, 300), la foto de la reina descalza (0,1 kg, 200) | Un brillito en el piso del probador | La evidencia principal es frágil: si se cae desde más de 1 m, se rompe y vale la mitad |

Los pesos y valores siguen la escala de la granja, el gimnasio, el consultorio y la pizzería: la principal vale unos
1000 y los extras suman 500.

## Si escapa
Si Don Suela ve a un policía levantar la evidencia principal (decisión 96), huye en monopatín
(`SuspectCar.KICK_SCOOTER`), perdiendo zapatos sueltos en las curvas (`ChaseDrops`).

## Qué se reutiliza
- Lo compartido de las historias ([historias.md](historias.md)): escondites sorteados, notas, 3 sospechas, la planilla,
  el patrullero, la escolta del dueño, la huida ([persecucion-final.md](persecucion-final.md)) y la pantalla del turno
  (`RaidCase`).
- De la pizzería y el consultorio: el dueño con su distracción con E (el teléfono → el timbre del banco de probar), lo
  frágil con multa (los platos → las cajas), el chismoso que pide algo a cambio (Tito y la porción → Lustrín y el
  lustrado), la evidencia que no va en un escondite (la caja fuerte de la pizza gigante → el zapato gigante), los "rigs"
  de cada historia y el online (`NpcSync`, `PropSync` y `ActionSync`).
- Del edificio: la puerta cerrada con llave en el bolsillo del dueño. De la pizzería: gatear por un hueco (el túnel del
  horno → el tobillo del zapato gigante).

## Atajos del panel de pruebas
- Abrir el allanamiento de la zapatería con una historia elegida (`--place=shoe_raid --story=<id>`), y "Zapatería
  (allanamiento, prueba)" en el menú.

## El orden para hacerlo (un PR chico por paso)
1. Los modelos nuevos: Don Suela, Lustrín y su cajón, la torre de cajas de zapatos, el banco de probar, el espejo
   grande, el zapato gigante de la vidriera, los zapatos con resorte y la máquina de coser suelas.
2. La zapatería como lugar de allanamiento en su manzana: salas, puertas, lo frágil, los zapatos con resorte y los
   escondites.
3. Don Suela: la recorrida, la denuncia y el timbre del banco de probar.
4. Lustrín y el lustrado.
5. El caso (`RaidCase`) con la primera historia: los relojes en las botas.
6. Las otras 5 historias, una por PR.
7. El sorteo de "Jugar" entre los allanamientos, la huida en monopatín y el online.

## Preguntas para Cristian
1. ¿Te gusta una zapatería (torres de cajas, zapatos con resorte, el zapato gigante), o prefieres otro local?
2. ¿Que Don Suela no deje levantar al policía que mide es gracioso o molesta? (Recomiendo probarlo así: es el precio
   de la distracción.)
3. ¿Lustrín pide que le dejes lustrar las botas, o algo más absurdo (que le traigas un cordón de cada color)?
