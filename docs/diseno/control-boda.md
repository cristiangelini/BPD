# BPD · Control de tránsito: Alcoholemia en la boda (propuesta, 25/10)

Sexta variante del control de tránsito ([control-transito.md](control-transito.md), variante 4;
[casos.md](casos.md), punto 8.4). Reusa el control de "Hora pico" y lo de las otras variantes
([control-payasos.md](control-payasos.md), [control-frutas.md](control-frutas.md),
[control-auto-lleno.md](control-auto-lleno.md), [control-auto-fantasma.md](control-auto-fantasma.md)): conos,
barrera, la fila y su medidor, papeles, baúl, denuncias, escolta, el sorteo por semilla y la persecución. Los números
son **(propuesta)** hasta probarlos jugando.

## La historia
El comisario: "¡Novatos! Hoy se casan Rosa y Tito y media ciudad va de fiesta al salón. Entre los invitados anda
El Colado: se mete en todas las bodas sin que nadie lo invite y se lleva los sobres de regalo. Armen un control de
alcoholemia en la salida: así revisamos a todos sin que sospeche. Y de paso, que nadie maneje borracho."

## Cómo es
1. Llegan 12 a 16 autos de la caravana de la boda: moños blancos, latas atadas atrás que suenan y bocinazos de
   festejo cada tanto. Entre ellos va **el auto de los novios** (blanco, con el cartel "Recién casados") y algunos
   autos comunes de la ciudad.
2. **Soplar:** el patrullero trae un **alcoholímetro** (se agarra con las manos, como la linterna). E con el
   alcoholímetro a un conductor lo hace soplar y la pantallita muestra un número de 0,0 a 2,0. Cada invitado dice algo
   de fiesta al soplar (hipo, canta, abraza al policía; 10+ frases con tr()).
3. **Los borrachos:** a los conductores que soplan más de 0,5 hay que **sacarles las llaves** (E de nuevo) y maneja
   otro del auto (la tía, el primo), que se cambia de asiento. Cada llave sacada suma 25; dejar pasar a un borracho
   resta 25 (se lo ve zigzaguear y voltear un cono).
4. **El Colado** maneja uno de los autos de la caravana. Es el único invitado que no tomó nada porque no estaba en la
   fiesta: sopla 0,0. Pero no es tan fácil: hay 2 o 3 **conductores designados** que tampoco tomaron y también soplan
   0,0.
5. **La pista buena:** E al conductor (los papeles) y preguntarle por la boda. Los invitados de verdad saben cómo se
   llaman los novios ("¡Viva Rosa y Tito!"); El Colado se equivoca de nombres ("¡Viva... Marta y Pepe!"). La radio da
   además una pista de él cada 60 s (color del auto, el moño de la corbata, la patente), como en Hora pico.
6. En el baúl de El Colado están los **sobres de regalo**. Detener a un conductor inocente suma denuncia y al segundo
   se pierde, como siempre (el auto de los novios también se puede detener, y es un escándalo).
7. **Se gana** deteniendo a El Colado y llevándolo al patrullero: 500, misma cuota que Hora pico. Llevar los sobres al
   baúl del patrullero suma 100 (como los relojes del Camión de frutas), más 25 por cada borracho sin llaves.
8. **Se pierde** si El Colado pasa el control: huye por la ciudad tirando latas y moños detrás (ChaseDrops). Si se
   escapa también ahí, se pierde el caso.
9. En "Jugar", el control de tránsito sale un sexto cada variante: Hora pico, Caravana, Camión de frutas, Auto lleno,
   Auto fantasma y Boda.

## Lo nuevo
- Los autos de la boda (moños, latas, cartel de los novios) y la variante `wedding`.
- El alcoholímetro: soplar, el número, las frases de fiesta.
- Sacar las llaves y el cambio de conductor; el borracho que se deja pasar zigzaguea.
- El plan: en qué auto va El Colado, los designados, los nombres de los novios (la semilla los elige de 10+ parejas) y
  sus pistas (sobre WantedPlan).
- Los sobres de regalo como prueba (+100 en el baúl).
- La persecución con latas y moños (ChaseDrops).

## Preguntas para Cristian
1. **¿El Colado sopla 0,0 pero también hay 2 o 3 conductores designados que soplan 0,0?**
   Recomiendo que sí: el alcoholímetro achica la lista, no da la respuesta.
2. **¿La pista buena es preguntar por los novios: El Colado se equivoca de nombres?**
   Recomiendo que sí: obliga a hablar con cada uno y los nombres cambian con la semilla.
3. **¿Sacarles las llaves a los borrachos suma 25 cada uno y dejarlos pasar resta 25?**
   Recomiendo que sí: es un control de alcoholemia de verdad y da trabajo a los que no buscan a El Colado.

## El orden para hacerlo (un PR chico por paso, apilados sobre el Auto fantasma)
1. Los autos de la boda en la fila: moños, latas, el auto de los novios (variante `wedding`).
2. El alcoholímetro: soplar, el número y las frases.
3. Los borrachos: sacar las llaves, el cambio de conductor y el que zigzaguea.
4. El plan: El Colado, los designados, los novios, las pistas, la radio y la pregunta por los novios.
5. Detener, escoltar, los sobres +100, sueldo, el escape con latas y el sorteo en "Jugar".
6. Online.

## Online
Como las otras variantes: el anfitrión decide la fila, los números del alcoholímetro, quién es El Colado y los
designados; cada PC ve los mismos autos, los mismos números, las llaves sacadas y el final ([online.md](online.md)).
