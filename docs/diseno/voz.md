# BPD · Voz

Los policías hablan con la voz de Steam (decisión 51): se escucha por cercanía (decisión 9) y es pulsar para hablar, con la opción de dejarla siempre abierta (decisión 68). Lo marcado con **(propuesta)** es mío y se ajusta en la primera prueba con dos cuentas reales.

## Cómo se habla
| Tecla | Qué hace |
|---|---|
| Mantener **V** | Hablar por cercanía: te escuchan los que están cerca, como en la vida real |
| Mantener **T** | Hablar por la radio: te escuchan todos, estén donde estén, con interferencia |

- **Voz siempre abierta:** una casilla en la sala, "Voz siempre abierta". Con ella marcada, la voz por cercanía sale sin apretar V. Se guarda en la PC (`user://ajustes.cfg`) **(propuesta)**: hasta que exista la pantalla de opciones, vive en la sala porque la voz solo sirve online.
- Mientras hablas, abajo a la izquierda aparece "Hablando" (o "Radio" con T) para que sepas que sale tu voz.
- Jugando solo no hay voz.

## Cómo se escucha
| Qué | Cómo **(propuesta)** |
|---|---|
| Cercanía | La voz sale de la cabeza del policía que habla. Se oye entera hasta 3 m y se apaga del todo a los 20 m. Con una pared (o el piso) entre los dos, se oye apagada y más baja: sin agudos y 8 dB menos |
| Radio | Se oye igual en todas partes, más finita y con ruido de radio (filtro de banda y estática). Hoy todos tienen radio; cuando la radio sea un ítem (decisión 36), solo habla y escucha el que la lleva |
| En la sala | No hay policías todavía: la voz se oye igual de fuerte para todos |
| Radio pirata | En esa historia la radio tiene más interferencia en toda la casa (historias.md); se suma cuando esté esa historia |

## Red
- La voz va directo de cada PC a las demás por la red de Steam, comprimida por Steam, sin pasar por el anfitrión para decidir nada.
- Por IP (las pruebas en una PC) no hay voz: depende de Steam.
- Se manda sin esperar confirmación: si se pierde un pedacito, no se repite (mejor un corte que una demora).

## Pruebas
- GUT: que la voz que llega de un jugador sale de su policía con la distancia de arriba, que la radio suena en todas partes, que tras una pared la voz cercana suena apagada, que V, T y "siempre abierta" deciden bien cuándo sale tu voz y que la casilla se guarda.
- En la PC de Cristian: que Steam graba el micrófono y lo devuelve. Escuchar a otro de verdad necesita dos PCs con dos cuentas (online.md).
