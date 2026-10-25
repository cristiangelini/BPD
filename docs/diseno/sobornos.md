# BPD · Sobornos y asuntos internos (aprobado, 25/10)

Pedido de Cristian (25/10): los policías pueden recibir sobornos de plata, el jugador elige si lo acepta o no, y si
se toman muchos sobornos empieza una investigación de asuntos internos. Vale para todos los casos: no es un caso
nuevo, es algo que pasa encima de cualquier turno. Los números son **(propuesta)** hasta probarlos jugando.

## El soborno (decisión 190)
1. **Quién ofrece:** cualquier persona que los policías puedan esposar (sospechosos, ladrones, presos, conductores,
   vecinos), nunca un compañero. La primera vez que un policía le aprieta las esposas, 1 de cada 4 en vez de dejarse
   esposar le ofrece plata: 100, 150, 200 o 250. Quién ofrece y cuánto sale de la semilla del caso, así es igual en
   todas las PC. Cada persona ofrece una sola vez por caso.
2. **Qué ve el jugador:** el globo del que ofrece ("Toma 200 y aquí no pasó nada") y en la mira
   "E: aceptar 200 · clic: esposar igual". Tiene 5 s para elegir; si no elige, nada pasa y puede volver a esposar.
3. **Aceptar (E):** la plata va al turno en una línea nueva, "Sobornos", que suma al total y a la cuota. A esa persona
   no se la esposa: queda libre y sigue con lo suyo (el culpable puede escaparse y el caso perderse).
4. **Rechazar (clic):** se lo esposa como siempre. El que nunca acepta no gana nada extra, solo la conciencia.
5. Premio de broma del fin de turno: "Más sobornos aceptados".
6. Solo elige el que esposa: online, el policía que aprieta las esposas ve la oferta en su pantalla y su elección
   llega a todas las PC.

## Asuntos internos (decisiones 191 y 192)
1. **Cuándo empieza:** cada soborno aceptado queda en la ficha de la partida (se guarda). Con **3 sobornos** aceptados
   en la partida, sea quien sea el policía, empieza la investigación. La pantalla de fin de turno lo avisa:
   "Asuntos internos abrió una investigación".
2. **El agente:** mientras dura la investigación, el agente de asuntos internos (el NPC pera de traje gris con
   carpeta) aparece en cada caso y sigue a los policías a unos 8 m, anotando en su carpeta. No se lo puede esposar
   (muestra la credencial).
3. **Atrapados:** aceptar un soborno a menos de 15 m del agente y a su vista hace que lo vea: ese soborno no suma,
   y el turno tiene una multa de 300 ("Asuntos internos"). La segunda vez que el agente los atrapa en la partida,
   los suspenden: la partida se pierde con "Suspendidos por asuntos internos".
4. **Sobornos a escondidas:** los que se aceptan lejos de él suman como siempre. El chiste es esconderse del agente
   para cobrar.
5. **Cómo termina:** si pasan **2 turnos** de investigación sin aceptar ningún soborno, la investigación se cierra
   ("No encontraron nada"), el agente se va y la ficha vuelve a 0.

## Qué se guarda (guardado.md)
Los sobornos aceptados de la partida, si hay investigación, cuántos turnos limpios lleva y cuántas veces los atrapó el
agente. Online lo guarda el anfitrión, como el resto de la partida.

## Preguntas para Cristian (respondidas: sí a las tres, 25/10)
1. **¿Ofrece cualquier persona esposable, 1 de cada 4 la primera vez, y aceptar deja libre al que ofrece?**
   Recomiendo que sí: así es una decisión de verdad (plata contra el caso) y aparece en todos los casos.
2. **¿La investigación empieza con 3 sobornos aceptados en la partida, contando a los 4 policías juntos?**
   Recomiendo que sí: la plata y la cuota son del grupo, y así uno coimero mete en problemas a todos.
3. **¿El agente sigue a los policías en cada caso, multa 300 si ve un soborno y a la segunda los suspende, y 2 turnos
   limpios cierran la investigación?** Recomiendo que sí: se puede seguir cobrando a escondidas, que es lo divertido.

## El orden para hacerlo (un PR chico por paso)
1. Este diseño, las cuentas (el sorteo de la oferta, la línea "Sobornos", la ficha de la partida y la investigación en
   `Campaign`) y la línea en la pantalla de fin de turno.
2. La oferta al esposar: el globo, la mira con E y clic, aceptar y rechazar, el premio de broma. Online.
3. El agente de asuntos internos en los casos: sigue a los policías, ve los sobornos, la multa y la suspensión.
   Online.
