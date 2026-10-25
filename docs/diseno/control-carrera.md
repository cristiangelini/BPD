# BPD · Control de tránsito: Carrera ilegal (propuesta, 25/10)

Séptima variante del control de tránsito ([control-transito.md](control-transito.md), variante 5;
[casos.md](casos.md), punto 8.5). Reusa el control de "Hora pico" y lo de las otras variantes
([control-payasos.md](control-payasos.md), [control-frutas.md](control-frutas.md),
[control-auto-lleno.md](control-auto-lleno.md), [control-auto-fantasma.md](control-auto-fantasma.md),
[control-boda.md](control-boda.md)): conos, barrera, la fila y su medidor, papeles, baúl, denuncias, escolta, el
sorteo por semilla y la persecución. Los pinchos son los de la persecución (ChaseTrap). Los números son
**(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! Esta noche hay picadas en la avenida y el que las organiza es El Turbo, el campeón: nunca
lo agarró nadie. Los corredores no paran en ningún control, así que les armé uno con pinchos. Ojo: que los vecinos
también pasan por ahí y no quiero gomas pinchadas de gente que va a comprar pan."

## Cómo es
1. La fila del control sigue como siempre con **autos comunes** (paran en la barrera, papeles, baúl). Entre ellos
   llegan **tandas de corredores**: 4 o 5 tandas de 2 o 3 autos, cada 30 a 45 s.
2. Los corredores se ven: **alerón**, un **número** grande en la puerta (1 a 99), **luces de neón** abajo y el caño
   de escape que tira chispas. Antes de cada tanda se juntan en la esquina de atrás y **rugen el motor 3 s**
   ("¡RRRUM!", el auto tiembla): es el aviso.
3. Después **largan a toda velocidad** (unos 22 m/s, el triple que un auto común), esquivan la fila por el otro
   carril y **no paran en la barrera: la voltean** (vuela la barrera, se vuelve a parar en 5 s).
4. **Los pinchos:** en el baúl del patrullero hay 2 tiras de pinchos (se agarran como la linterna). Se tiran en la
   calle y se despliegan de vereda a vereda del carril. Un auto que pasa por arriba **pincha las 4 gomas**, sale
   haciendo chispas y se frena a los pocos metros. Con E en la soga se **sacan los pinchos** de la calle (se
   enrollan en 1 s) para dejar pasar a un auto común.
5. **Pinchar a un corredor suma 25** (la multa por picada): baja, se queja ("¡Era mi mejor tiempo!", 10+ frases con
   tr()) y se va caminando. **Pinchar un auto común es denuncia**, y a la segunda se pierde el caso, como detener a
   un inocente. Esposar a un corredor pinchado que no es El Turbo también es denuncia (ya pagó la multa): así las
   pistas de la radio siguen importando.
6. **El Turbo** va en una de las tandas del medio (la 3, 4 o 5). La radio da una pista de él cada 60 s, como en Hora
   pico: el color del auto, el número de la puerta, el color del neón, el alerón (grande, chico, ninguno). Los otros
   corredores se parecen pero no son iguales.
7. **Se gana** pinchando a El Turbo, esposándolo y llevándolo al patrullero: 500, misma cuota que Hora pico, más 25
   por cada corredor pinchado. El trofeo de las picadas está en su baúl: llevarlo al baúl del patrullero suma 100.
8. **Se pierde** si El Turbo pasa el control: sigue de largo por la ciudad (persecución). Va más rápido que los otros
   sospechosos, pero en cada esquina **hace un trompo** para lucirse y pierde 2 s. Si se escapa también ahí, se
   pierde el caso.
9. En "Jugar", el control de tránsito sale un séptimo cada variante: Hora pico, Caravana, Camión de frutas, Auto
   lleno, Auto fantasma, Boda y Carrera.

## Lo nuevo
- Los autos de carrera (alerón, número, neón, chispas del caño) y la variante `race`.
- Las tandas: juntarse en la esquina, rugir, largar, esquivar la fila y voltear la barrera.
- Las tiras de pinchos del baúl: tirarlas, desplegarlas, sacarlas con la soga; las gomas pinchadas.
- El plan: en qué tanda va El Turbo, su auto y sus pistas (sobre WantedPlan).
- El trofeo como prueba (+100 en el baúl).
- La persecución con trompos en las esquinas.

## Preguntas para Cristian
1. **¿Los corredores no paran en la barrera (la voltean) y solo se los frena con los pinchos?**
   Recomiendo que sí: es lo que hace distinta a esta variante y obliga a usar los pinchos.
2. **¿Pinchar a un corredor cualquiera suma 25 y pinchar un auto común es denuncia?**
   Recomiendo que sí: da ganas de tirar los pinchos, pero hay que sacarlos a tiempo para los vecinos.
3. **¿Antes de cada tanda los corredores rugen 3 s en la esquina, como aviso?**
   Recomiendo que sí: sin aviso, a 22 m/s no da el tiempo de tirar los pinchos.

## El orden para hacerlo (un PR chico por paso, apilados sobre la Boda)
1. Los autos de carrera: alerón, número, neón, chispas (variante `race`).
2. Las tandas: juntarse, rugir, largar, esquivar la fila y voltear la barrera.
3. Los pinchos: tirarlos, desplegarlos, sacarlos con la soga; las gomas pinchadas y la queja del corredor.
4. El plan: El Turbo, sus pistas, la radio, +25 por corredor, denuncia por auto común.
5. Detener, escoltar, el trofeo +100, sueldo, el escape con trompos y el sorteo en "Jugar".
6. Online.

## Online
Como las otras variantes: el anfitrión decide la fila, las tandas, cuándo largan y quién es El Turbo; los pinchos son
objetos que se agarran (PropSync) y cada PC ve los mismos autos, las mismas gomas pinchadas y el final
([online.md](online.md)).
