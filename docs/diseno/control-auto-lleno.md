# BPD · Control de tránsito: El auto con 20 personas (propuesta, 25/10)

Cuarta variante del control de tránsito ([control-transito.md](control-transito.md), variante 3;
[casos.md](casos.md), punto 8.3). Reusa el control de "Hora pico", la Caravana ([control-payasos.md](control-payasos.md))
y el Camión de frutas ([control-frutas.md](control-frutas.md)): conos, barrera, la fila y su medidor, papeles, baúl,
denuncias, escolta, la gente que baja del auto y hay que volver a meter, el sorteo por semilla y la persecución. Los
números son **(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! Los Apretados, una banda de carteristas, vuelven del partido todos juntos en un solo auto
para no pagar el colectivo. Son exactamente %d, ni uno más ni uno menos. Hoy salen todas las familias numerosas del
estadio, así que cuenten bien."

## Cómo es
1. Llegan 12 a 16 autos de la ciudad, como en Hora pico. La mayoría trae 1 a 4 personas, pero 4 o 5 vienen
   **repletos**: de 9 a 22 personas apretadas contra los vidrios (se ven caras aplastadas desde afuera).
2. La banda es de 14 a 20 personas (sale con la semilla). Entre los repletos hay 2 o 3 que tienen casi el mismo
   número (uno o dos de diferencia), así que mirar por el vidrio no alcanza: hay que contarlos.
3. **La puerta** se abre con las manos y la gente sale como un tapón de champán, de a una por segundo, y se queda
   charlando alrededor del auto (como los payasos de la Caravana, con los modelos de vecinos de la ciudad).
4. **Contar:** con E sobre una persona se le pega una calcomanía con su número (1, 2, 3...). El número se ve en la
   espalda, así ningún policía la cuenta dos veces. Algunos se quedan adentro (la abuela que no se baja, el bebé en
   el portaequipajes): con E sobre la puerta abierta se cuentan los que quedan adentro.
5. **Volver a meterlos:** el auto no arranca hasta que vuelven a estar todos adentro, como en la Caravana. Mientras
   tanto la fila se impacienta. La radio sigue dando una pista del auto cada 60 s (color o patente), como en Hora pico.
6. Detener a un conductor inocente suma denuncia y al segundo se pierde, como siempre.
7. **Se gana** deteniendo al conductor de la banda (el que tiene las llaves) y llevándolo al patrullero: 500, misma
   cuota que Hora pico.
8. **Se pierde** si el auto de la banda pasa el control: huye por la ciudad, lento por el peso, y en cada curva salta
   un pasajero que sale corriendo (como los muebles del camión de mudanza). Si se escapa también ahí, se pierde el caso.
9. En "Jugar", el control de tránsito sale un cuarto Hora pico, un cuarto Caravana, un cuarto Camión de frutas y un
   cuarto Auto lleno.

## Lo nuevo
- `CrowdedCar`: el auto repleto con caras contra los vidrios y la gente que sale y vuelve (sobre ConvoyClown).
- La calcomanía numerada y el contador por auto (lo ve todo el equipo).
- El plan de la banda: cuántos son, los repletos parecidos y las pistas del auto (sobre WantedPlan).
- Las multas por exceso de pasajeros (si Cristian dice que sí).
- Pasajeros que saltan del auto en la persecución (ChaseDrops).

## Preguntas para Cristian
1. **¿Se cuenta pegándole a cada persona una calcomanía con su número (E), para que nadie cuente dos veces?**
   Recomiendo que sí: así se puede contar entre los 4 sin perder la cuenta, y queda gracioso ver a todos numerados.
2. **¿A un auto inocente repleto se le puede hacer una multa por exceso de pasajeros que suma 20 al sueldo?**
   Recomiendo que sí, así contar los repletos inocentes también sirve y no es tiempo perdido.
3. **¿Si la banda se escapa, en la persecución salta un pasajero en cada curva y sale corriendo?**
   Recomiendo que sí, reusando lo del camión de mudanza; igual alcanza con detener al conductor.

## El orden para hacerlo (un PR chico por paso, apilados sobre el Camión de frutas)
1. Los autos repletos en la fila, con caras contra los vidrios (variante `crowded_car`).
2. La puerta, la gente que sale y vuelve a entrar.
3. Contar: la calcomanía numerada y los que quedan adentro.
4. El plan: cuántos son, repletos parecidos, pistas del auto y la radio.
5. Multas, detener y escoltar, sueldo.
6. El escape con pasajeros que saltan y el sorteo en "Jugar".
7. Online.

## Online
Como la Caravana: el anfitrión decide la fila, cuántos van en cada auto y quién es la banda; cada PC ve los mismos
autos, la misma gente, las calcomanías con su número, las multas y el final ([online.md](online.md)).
