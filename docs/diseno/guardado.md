# BPD · Guardado de la partida

Una partida son 5 turnos de guardia y se guarda entre turnos (decisiones 16 y 59). Ejemplo: una partida que se deja en el turno 2 se retoma en el 3 con la misma plata, los mismos ítems y los casos que siguen. Lo marcado con **(propuesta)** es mío y lo confirma Cristian.

## Qué se guarda
| Qué | Detalle |
|---|---|
| Turno | El próximo turno a jugar, de 1 a 5 |
| Plata | La del grupo: suma el total de cada turno (sueldo + evidencia − multas) **(propuesta)** |
| Ítems | La lista de equipo comprado. Hoy está vacía porque todavía no hay tienda; queda lista para cuando exista |
| Casos que siguen | La partida tiene su propia semilla y de ella sale la semilla del caso de cada turno. Así, el turno 3 de una partida es siempre el mismo caso, se juegue de corrido o retomado |
| Historial | Qué caso se jugó en cada turno, si se resolvió, el total y si se cumplió la cuota |

## Cuándo y dónde
- Se guarda **al terminar cada turno**, cuando aparece la pantalla de fin de turno. No se guarda a mitad de un caso.
- Un solo archivo de partida por ahora (`user://partidas/partida.json`) **(propuesta)**. Partida nueva lo pisa.
- Online lo guarda **solo el anfitrión** (online.md, "Guardado"): la partida es suya y los amigos entran a su sala para seguirla. Los invitados ven el turno y la plata en la pantalla de fin de turno.

## En el menú
- **Jugar** empieza una partida nueva en el turno 1.
- **Continuar** aparece si hay una partida sin terminar y la retoma en el turno que sigue.
- En la sala, el anfitrión tiene **Empezar caso** (partida nueva) y **Continuar partida** si hay una guardada.
- **Otro turno** en la pantalla de fin de turno juega el turno siguiente de la misma partida. Después del turno 5, o si no cumplieron la cuota, la partida termina y ese botón ya no aparece.

## La cuota
- Cada turno tiene una cuota: 800 el primero y 100 más cada turno (800, 900, 1000, 1100, 1200; decisión 88, comisaria.md). Es una meta, no plata que se cobra.
- **Si no cumplen la cuota, la partida se pierde:** "Suspendidos" y "No cumplieron la cuota: partida perdida". Queda guardada como perdida y ya no se puede continuar. Cuando exista la fuga de la cárcel, eso cambia (decisión 88).
- **Si cumplen las 5 cuotas:** "¡Ascendidos!" y la partida termina.
