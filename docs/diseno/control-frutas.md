# BPD · Control de tránsito: Camión de frutas (propuesta, 24/10)

Tercera variante del control de tránsito ([control-transito.md](control-transito.md), variante 10;
[casos.md](casos.md), punto 8.10). Reusa el control de "Hora pico" y lo de la Caravana ([control-payasos.md](control-payasos.md)):
conos, barrera, la fila y su medidor, papeles, denuncias, escolta, el sorteo por semilla y la persecución. Los números
son **(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! Es la feria de la fruta y pasan todos los fruteros por la esquina. Uno trae algo escondido
adentro de las sandías. No me rompan todas, que después los fruteros me llenan la oficina de quejas."

## Cómo es
1. Llegan 10 a 14 **camioncitos de fruta** abiertos atrás, cada uno con 6 a 10 sandías en la caja (se ven desde la
   vereda) y algún cajón de otra fruta.
2. Las pistas son del camión y del frutero, como en Hora pico: color del camión, el cartel pintado ("Frutas Don X"),
   el sombrero del frutero y qué otra fruta lleva (bananas, naranjas, ananás).
3. **Revisar una sandía:** se agarra con las manos y se baja del camión (pesa 8 kg, uno solo puede). Con E encima
   se le da un golpecito: la normal suena "toc toc" y la del contrabando suena hueca ("tonc"). En el camión buscado hay
   2 o 3 sandías huecas; en algunos inocentes, 1 sandía "pasada" que también suena raro (para que no sea tan fácil).
4. **Romperla:** se tira al piso fuerte (o se le pega con la linterna). Se parte con jugo, y adentro hay pulpa roja,
   o el contrabando (relojes de oro de mentira, que son la evidencia).
5. Cada sandía rota de un camión inocente es una queja del frutero (se descuenta del sueldo). Detener a dos fruteros
   inocentes pierde el caso, como siempre.
6. **Se gana** deteniendo al frutero buscado y llevándolo al patrullero: 500, y +100 si además llevan al patrullero
   un reloj de oro de una sandía rota.
7. **Se pierde** si el camión buscado pasa el control: huye por la ciudad y en cada curva se le caen sandías que
   ruedan por la calle (como los muebles del camión de mudanza). Si se escapa también ahí, se pierde el caso.
8. En "Jugar", el control de tránsito sale un tercio Hora pico, un tercio Caravana y un tercio Camión de frutas.

## Lo nuevo
- El camioncito de fruta (modelo procedural, 4 colores, caja abierta atrás) y la sandía (con su versión partida).
- `Watermelon`: Grabbable de 8 kg, golpecito con E, se rompe con un golpe fuerte; hueca, normal o pasada.
- El plan del buscado con pistas de camión y frutero (sobre WantedPlan, como la Caravana).
- Las quejas por sandía rota y el reloj de oro como evidencia extra.
- Sandías que caen del camión en la persecución (ChaseDrops).

## Preguntas para Cristian
1. **¿Las sandías se revisan con un golpecito (E) que suena distinto si están huecas, y para estar seguro hay que
   romperlas?** Recomiendo que sí: el sonido es la pista rápida y romperla es la prueba, con el riesgo de la queja.
2. **¿Cada sandía rota de un frutero inocente es una queja que se descuenta (propongo 20 cada una)?** Recomiendo que
   sí, así no conviene romper todo a lo loco.
3. **¿Si el camión se escapa, la persecución tira sandías rodando por la calle?** Recomiendo que sí, reusando lo del
   camión de mudanza.

**Respuestas de Cristian (25/10):** sí a las tres.

## El orden para hacerlo (un PR chico por paso, apilados sobre la Caravana)
1. Los camioncitos de fruta en la fila, con sus sandías en la caja (variante `fruit_truck`).
2. La sandía: agarrarla, golpecito, romperla con jugo y lo de adentro.
3. El plan: pistas del camión y del frutero, sandías huecas y pasadas, la radio.
4. Quejas por sandías rotas, el reloj de oro, detener y escoltar, sueldo.
5. El escape con sandías rodando y el sorteo en "Jugar".
6. Online.

## Online
Como la Caravana: el anfitrión decide la fila, qué sandías son huecas y quién es el buscado; cada PC ve los mismos
camiones, sandías (PropSync), las rotas, las quejas y el final ([online.md](online.md)).
