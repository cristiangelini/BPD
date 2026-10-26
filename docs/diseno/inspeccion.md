# BPD · La inspección final (26/10)

Decisión 106: el objetivo de la partida es salvar la comisaría, que la ciudad quiere convertir en un estacionamiento.
Cristian eligió (26/10) que el último turno sea un caso especial en el que la ciudad decide. Lo marcado con
**(propuesta)** es mío y lo confirma Cristian.

## La idea
En el turno 10 (el último) llega la inspectora de la ciudad. Acompaña a los policías durante todo el turno y anota en
su portapapeles todo lo que hacen bien y todo lo que hacen mal. Al volver a la comisaría lee su informe en la oficina
del comisario, y ese informe decide si la comisaría se salva o cierra. El chiste es tener que trabajar bien con
alguien mirando, cuando todo sale mal igual.

## La inspectora
- **Severina Regla (propuesta):** funcionaria de la ciudad, con traje gris, anteojos, portapapeles y lapicera. Es un
  modelo pera de `tools/modelgen` y se cae como ragdoll como todos.
- Aparece en la sala de guardia con el comisario, que la presenta nervioso: "Ella es la inspectora Regla. Sonrían.
  ¡Sonrían más!".
- **Va con ellos a todos lados (propuesta):** sube al asiento de atrás del patrullero (E: "Suba, inspectora"), baja en
  el lugar del caso y camina detrás del grupo a 3 m. Si la dejan atrás, protesta y anota.
- Habla en globitos cortos cada vez que anota algo ("Anotado." "Interesante..." "¡Esto va al informe!").

## El informe (la nota)
La nota arranca en **50 de 100 (propuesta)** y se ve en la planilla (Q) como "Informe de la inspectora". Solo cuenta lo
que pasa a **15 m o menos de ella y a su vista (propuesta)**, como el agente de asuntos internos (sobornos.md).

| Qué ve | Nota (propuesta) | Qué dice |
|---|---|---|
| El caso resuelto | +25 | "Eficaces. Raro, pero eficaces." |
| Un sospechoso esposado | +5 | "Correcto procedimiento." |
| Evidencia entregada en el patrullero | +3 por cada una | "Prolijo." |
| Un choque fuerte del patrullero | −5 | "¡Mi cuello!" |
| Un adorno o algo frágil roto | −2 | "Eso lo paga la ciudad." |
| Esposar o tasear a un compañero | −5 | "¿Entre ustedes?" |
| Un soborno aceptado | −20 | "Ajá. Ajá." |
| Que algo la golpee (un objeto, un policía, una puerta) | −10 | "¡Esto va al informe!" |
| Dejarla atrás a más de 40 m | −1 cada 10 s | "¿Hola? ¿Oficiales?" |
| Comerse una dona delante de ella | −1 | "Típico." |

La nota no baja de 0 ni pasa de 100.

## Cómo termina
- El turno termina como siempre, al estacionar en la comisaría. La inspectora entra a la oficina del comisario, los
  policías la siguen y ella lee el informe en voz alta: lo mejor y lo peor que anotó, en 3 o 4 frases.
- **Con 60 o más (propuesta) la comisaría se salva:** "¡Ascendidos! La comisaría sigue abierta.", con los premios de
  toda la partida.
- **Con menos de 60, la comisaría cierra:** "La comisaría cierra. Partida perdida." y se ve el cartel de
  "Estacionamiento" en la fachada.
- **La cuota del turno 10 no cuenta (propuesta):** en el último turno decide solo el informe. La plata del caso suma a
  la caja igual, para los premios.
- Si el caso se pierde (el sospechoso escapa, se pierde la evidencia), el informe no suma los +25 pero se lee igual:
  todavía se puede salvar la comisaría con buen comportamiento.

## Lo que se reusa
- El turno y el caso del día: el turno 10 sortea su caso como cualquier otro (PlaceDraw), y la inspectora se suma
  encima.
- El agente de asuntos internos (sobornos.md): cómo un NPC sigue al grupo y ve lo que pasa a su vista.
- La charla del comisario (CaseBriefing) para presentarla y para leer el informe.
- ChaseDamages para los choques, las multas de adornos rotos y `Bribes` para los sobornos.
- NpcSync y CaseSync para el online.

## El orden para hacerlo (un PR chico por paso)
1. Este diseño.
2. La inspectora: el modelo, que siga al grupo a pie y que suba y baje del patrullero.
3. El informe: la nota, lo que ve, lo que dice y la fila en la planilla.
4. El turno 10 es la inspección: la presentación del comisario, la lectura del informe y el final (se salva o cierra).
5. Online.

## Preguntas para Cristian
1. ¿En el último turno decide solo el informe (recomendado), o hace falta llegar a la cuota y al informe?
2. ¿La inspectora va con ellos a todos lados (recomendado), o se queda en la comisaría y los mira por la radio?
3. ¿Aprobar con 60 de 100 (recomendado), o más difícil (70)?
