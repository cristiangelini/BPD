# BPD · Juego online

De 1 a 4 amigos online por Steam (decisión 7), con lobby e invitaciones de Steam (decisión 49) y voz de Steam por proximidad (decisiones 9, 51 y 68). Este archivo dice cómo se arma la red y en qué orden. Lo marcado con **(propuesta)** es mío y se confirma en la primera prueba online con dos cuentas reales.

## Quién manda
- **Un jugador es el anfitrión** (el que crea la sala). Su juego es el que vale: simula los objetos, la física, los NPC, el caso, la plata y el guardado (decisión 50).
- **Cada jugador mueve su propio policía** en su PC y le avisa al resto dónde está, para que caminar no tenga demora (decisión 50).
- Lo que un jugador hace sobre el mundo (agarrar, abrir, usar, preguntar) se le pide al anfitrión, que lo hace y se lo muestra a todos. Si dos piden lo mismo a la vez, gana el primero que llega.
- Sin servidores propios: el anfitrión es uno de los cuatro, como en R.E.P.O. y PEAK.

## Cómo se conectan
| Qué | Cómo |
|---|---|
| En el juego final | Sala de Steam: el anfitrión crea la sala, invita desde Steam y los amigos entran con "Unirse a la partida". El tráfico va por la red de Steam (GodotSteam), sin abrir puertos. |
| Para probar (desarrollo) | Por IP con ENet, puerto 7777 **(propuesta)**. Dos ventanas en la misma PC: `godot --path . -- --host` y `godot --path . -- --join=127.0.0.1`. |
| Máximo | 4 jugadores. El quinto que intenta entrar queda afuera, aunque estén en un caso. |
| Color de cada uno | El orden de llegada da el lugar 1 a 4, y el lugar da el color de piel (rosa, naranja, lima, violeta; decisión 72). Si alguien se va, su lugar queda libre para el próximo. |

## Probar con Steam
- Una vez por PC: `powershell -ExecutionPolicy Bypass -File tools/godotsteam.ps1` baja GodotSteam a `addons/godotsteam` (no se sube al repo) y después `godot --headless --path . --import`.
- Steam tiene que estar abierto antes de arrancar el juego. Por ahora usa el AppID 480 (Spacewar), el de prueba de Valve, hasta que BPD tenga el suyo.
- En la sala aparece **Crear sala de Steam** (o directo: `godot --path . -- --host-steam`); con la sala abierta, **Invitar amigos** abre la ventana de Steam. El amigo acepta la invitación en Steam y entra solo (también si tenía el juego cerrado: Steam lo abre con `+connect_lobby`).
- Steam deja una sola cuenta por PC: para probar que alguien se une hacen falta dos PCs con dos cuentas.
- Sin GodotSteam o sin Steam abierto, la sala ofrece solo IP, como antes.

## La sala
- Desde el menú, **Jugar con amigos** abre la sala: Crear sala, Unirse y la lista de los policías conectados, cada uno con su color.
- **Nombres:** cada uno aparece con su nombre de Steam en la lista de la sala y flotando sobre su policía, en su color de piel; sin Steam, "Policía N" **(propuesta)**.
- Solo el anfitrión ve **Empezar caso**. Al apretarlo, el anfitrión sortea el caso (lugar e historia, con la misma semilla de siempre) y todos abren el mismo lugar con la misma semilla.
- **Jugar** (solo) sigue igual, sin red.
- **Entrar a mitad de un caso:** el que entra a la sala durante un caso (porque llegó tarde o se le cortó) va directo al mismo caso: aparece en el punto de partida con su color y ve todo como está en ese momento (objetos, NPC, pistas y lista). El quinto sigue quedando afuera.

## Si alguien se va
- **Se va un jugador:** su policía desaparece y el caso sigue con los demás. Lo que tenía en las manos se cae.
- **Se va el anfitrión:** todos vuelven a la pantalla de la sala con el aviso "El anfitrión cerró la sala", también si estaban en medio de un caso. Lo jugado hasta el último guardado no se pierde (ver "Guardado").
- **No se pudo entrar:** aviso "No se pudo entrar a la sala" y se queda en la sala.

## Qué se sincroniza
| Qué | Quién lo simula | Qué ven los demás |
|---|---|---|
| Policía (posición, giro, cabeza, agachado) | Su dueño | Copia suavizada, unas 20 veces por segundo **(propuesta)** |
| Lo que el policía tiene en la mano (ariete, objeto agarrado) | Su dueño pide, el anfitrión confirma | El mismo objeto en la misma mano |
| Objetos con física (cajas, evidencia, adornos, panes) | Anfitrión | Posición y giro copiados; los rotos se rompen en todos |
| Puertas, cajones, caja fuerte, baúl del patrullero | Anfitrión | Su estado (abierta, rota, combinación) |
| Patrullero | Anfitrión, con los controles que le manda el que maneja **(propuesta)**: así lo que va en el baúl viaja con el auto en todas las PCs | Copia suavizada; los de adentro viajan con él |
| NPC (abuelo, vecina, chismosa, Marta, clientes, Michi, palomas, Ramiro, la señora del caniche y los clientes de la peluquería) | Anfitrión | Posición, animación, lo que dicen, la denuncia y la toalla del cliente |
| Perros, gatos y tortugas | Anfitrión, como objetos | Se mueven solos solo en la PC del anfitrión; en las otras siguen su copia |
| Caso (historia, pistas, sospecha marcada, entrega, denuncia, multas) | Anfitrión | La lista de Q y los avisos iguales para todos |
| Plata, ítems y turno | Anfitrión | La pantalla de fin de turno igual para todos |

## Herramientas
- El cinturón se ve igual en todas las PCs: qué herramienta tiene cada uno en la mano, la linterna prendida o apagada (F) y las esposas. Como las demás acciones, el que la usa le pide al anfitrión y el anfitrión la repite en todos.
- Esposar va a quien apuntó el que esposa en su PC; liberar con E también pasa en todas.
- **Cámara y huellas:** la PC del que saca la foto decide qué salió en ella; el flash, el rollo, la queja del dueño y las pistas pasan en todas, y la foto cuenta para el premio al fotógrafo. Las huellas también se revelan en todas y las del dueño van a la lista de todos.
- La armería, las donas, los guantes y la carretilla van en los pasos que siguen.

## Menú con Esc
- **Esc** en medio de un caso abre un menú: **Seguir**, **Invitar amigos** (solo el anfitrión, con Steam), la casilla **Voz siempre abierta** y **Salir de la sala** (o **Salir al menú** jugando solo). Esc otra vez lo cierra.
- Jugando solo el juego se detiene mientras está abierto. Online no puede: dice "Tus compañeros siguen jugando." **(propuesta)**
- Si sale el anfitrión, la sala se cierra y los demás vuelven a la pantalla de la sala con el aviso.

## Guardado
- Lo guarda **solo el anfitrión**, al final de cada turno (decisiones 16 y 59). La partida es del anfitrión: para seguirla, él la abre y los amigos entran a su sala.
- La plata y los ítems son del grupo, no de cada jugador **(propuesta)**: así no importa si un amigo falta un día.
- El detalle va en su paso (abajo), con su propio archivo de diseño.

## Pasos
Un PR chico por paso, cada uno con sus pruebas GUT.
1. **Sala y conexión:** la red base (anfitrión, unirse, lugares 1 a 4, avisos), la sala en el menú y que todos abran el mismo caso. Por IP; se ven solo a sí mismos todavía.
2. **Steam:** GodotSteam, sala de Steam, invitaciones y prueba con dos cuentas reales (lección de Dread Warden).
3. **Policías sincronizados:** cada uno ve a los otros tres caminar, con su color, y las manos de cada uno.
4. **Objetos y física:** agarrar, cargar entre varios, tirar, romper, puertas, cajones y patrullero.
5. **NPC y el caso:** NPC, pistas, sospechas, entrega y la pantalla de fin de turno para todos.
6. **Guardado entre turnos:** plata, ítems y casos que siguen.
7. **Voz por proximidad** con la voz de Steam ([voz.md](voz.md)).
