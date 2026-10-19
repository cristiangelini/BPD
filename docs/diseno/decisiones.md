# BPD · Buddies Police Department · Decisiones

Fuente de verdad del diseño. Cada decisión lleva un número que no cambia. Si una decisión cambia, se tacha y se agrega una nueva con número nuevo. Solo Cristian decide. Respuestas del 19/10/2026 a las preguntas del proyecto (archivos `diseno/preguntas-y-pasos.md` y `preguntas-2.md`); entre paréntesis, la pregunta de origen.

## Idea y tono
1. Los 4 son policías novatos e inútiles de la misma comisaría. El chiste es que todo les sale mal. (A1)
2. Ciudad genérica de película, sin referencias argentinas ni de ningún país en particular. (A2, L2)
3. Mundo creíble; el caos lo hacen la física y los jugadores, como R.E.P.O. y PEAK. (A3)
4. Armas de fuego con efectos ridículos (balas de pintura, confeti), además de las herramientas no letales. (A4)
5. Los NPCs nunca mueren: se desmayan o quedan detenidos. (A5)
6. Nombre: **BPD · Buddies Police Department**. (A6)

## Jugadores y plataforma
7. De 1 a 4 jugadores online con amigos por Steam. (B1)
8. Se puede jugar solo, sin compañeros IA. (B2)
9. Voz integrada por proximidad; la radio llega lejos con interferencia. (B3)
10. PC con Steam, teclado y mouse; el mando es un extra. (B4)

## Cámara y aspecto
11. Primera persona. (C1)
12. 3D low poly simple, con colores fuertes y personajes con física floja (ragdoll). (C2)
13. Los policías se personalizan con cosméticos (cara, gorra, bigote, uniforme, colores). (C3)
14. Referencia visual: una mezcla de R.E.P.O., PEAK y Dear Passengers. (N2)

## Estructura de la partida
15. Ciclo por turnos de guardia. Empiezan en la comisaría, el comisario reparte los casos del día, salen a resolverlos y vuelven. Al final del turno hay una cuota; si no la cumplen, los suspenden. (D1)
16. La partida se guarda entre turnos. Ejemplo: una partida de 5 turnos que se deja en el turno 2 se retoma en el 3 con los mismos ítems, la misma plata y los casos que siguen. (D2)
17. Si fallan, terminan presos en su propia comisaría y tienen que escaparse. (D3)
18. Ascensos de rango entre partidas que desbloquean casos, herramientas y cosméticos. El poder dentro de la partida arranca de cero. (D4)
19. Cada tipo de caso tiene como mínimo 10 variantes distintas, con su propio mapa y su vuelta de tuerca. En cada partida salen al azar. Dentro de cada variante, además, cambian dónde está la evidencia, quién es el culpable, qué sospechosos y vecinos aparecen y por dónde escapa el sospechoso. Catálogo en [casos.md](casos.md). (D5, preguntas 2 · 1)

## La comisaría (base)
20. En la comisaría hay armería (comprar y retirar equipo), celdas para los presos, papeleo absurdo como minijuego y el tablero del caso con hilo rojo. (E1 a, b, e, f)
21. Hay un comisario NPC gritón que reparte los casos, pone la cuota y aparece en el peor momento. (E2)
22. La comisaría se mejora de a poco (patrulleros, celdas, café). (E3)

## Momentos
23. **Allanamiento:** es un tipo de caso. Llegan con orden judicial ~~y tiempo límite~~ (sin tiempo límite, ver 66), tiran la puerta, buscan la evidencia y la cargan entre todos hasta el patrullero sin romperla. (F1)
24. **Persecución:** los 4 van en el mismo patrullero y cada uno tiene una tarea (manejar, radio y mapa, red o pinchos por la ventana, sirena y megáfono). (F2)
25. La persecución es las dos cosas: un tipo de caso propio y también el final de cualquier caso en el que el sospechoso se escapa. (F3)
26. **Detective:** en la escena del crimen buscan pistas físicas, las llevan al tablero y acusan a un sospechoso. Si se equivocan, el comisario se enoja. (F4)
27. **Interrogatorio:** el sospechoso es un NPC con un medidor de nervios y otro de abogado. Se juega a policía bueno y policía malo con acciones absurdas. (F5)
28. **Infiltración:** van disfrazados y tienen que pasar desapercibidos mientras juntan evidencia. Si los descubren, hay pelea o persecución. (F6)
29. **Cárcel:** tiene dos partes. Una son los casos en la cárcel (motín, cuidar presos). La otra es escaparse de la propia comisaría cuando los detienen (decisión 17). (F7, D3)
30. **Corrupción:** coimas en grupo. Más coimas dan más plata, pero llenan el medidor de Asuntos Internos; cuando se llena, vienen a investigarlos. (F8)
31. Primer caso del prototipo: el allanamiento con la vuelta a la comisaría. Lo eligió Claude porque Cristian se lo dejó. (F9)
32. Casos extra: control de tránsito, protección de un político y robo a un banco. (F10)

## NPCs
33. NPCs: delincuentes con personalidad, vecinos, prensa que filma y baja la imagen, y Asuntos Internos. Sin perro por ahora. (G1)
34. Los delincuentes huyen, empujan, tiran cosas y se esconden; a veces pegan. (G2)

## Equipo, física y muerte
35. Cada policía lleva 4 ranuras. (H1)
36. Herramientas: esposas, taser, macana, red, linterna, radio, cámara de fotos, kit de huellas, ariete, megáfono, conos, pinchos para autos y donas. (H2)
37. Hay fuego amigo: el taser y la macana también afectan a los compañeros. (H3)
38. Cuando a un policía lo bajan, queda desmayado y un compañero lo levanta o lo carga al patrullero. Si nadie llega a tiempo, se lo lleva la ambulancia y vuelve después con una multa. (I1)
39. Mucha física: casi todo se agarra, se tira, se rompe y se carga. (I2)

## Economía
40. La plata sale del sueldo por caso, las coimas y las multas, y se gasta en equipo y mejoras. (J1)
41. Al final de cada turno hay premios en chiste ("más veces tasereado por un compañero"). (J2)

## Textos y sonido
42. Español neutro con "tú". (K1)
43. Todos los textos van por `tr()` desde el primer día. Idiomas: español, inglés y portugués. (K2)
44. Glosario: se dice "caso" (no misión), "sospechoso" (no enemigo) y "comisario" (no jefe). (K3)
45. Los NPCs hablan con ruiditos y frases cortas cómicas, sin doblaje completo. (L1)
46. Música original y genérica: la radio del patrullero pasa temas inventados de varios estilos y en las persecuciones suena música de tensión. Nada de un país en particular (decisión 2). (L2, preguntas 2 · 3)

## Tecnología
47. Godot 4.7 con GDScript tipado. (M1)
48. Render Forward+. (M2)
49. Steam desde el primer día (GodotSteam, lobby e invitaciones), probado con dos cuentas reales en la primera semana. (M3)
50. Física en red: lo que mejor funcione en tiempo real. Para empezar, el host simula los objetos y cada jugador mueve su propio cuerpo para que no haya demora al caminar. Se mide en la primera prueba online. (M4)
51. Voz por proximidad con la voz de Steam. (M5)

## Arte y negocio
52. ~~Cajas y formas simples hasta que el juego sea divertido. Después se suma arte con aprobación de Cristian, y el arte de IA nunca es el final. (N1)~~ Reemplazada por la 71.
53. Meta: vender en Steam. Precio y demo para Next Fest quedan por decidir. (O1 a O3)
54. Pensado para streamers (momentos para clips), sin botón para que el chat moleste. (O4)

## Cómo trabajamos
55. Repo nuevo y privado, aparte de wgt y JUEGO. Claude pregunta antes de crearlo. (P1)
56. Se siguen las reglas de Steam 2 ([reglas-de-trabajo.md](reglas-de-trabajo.md)), con las adaptaciones que se anotan en ese archivo. (P2)
57. Para ver los avances, Cristian abre el juego y da el OK; es lo que menos tokens gasta. Los videos quedan para cuando él los pida. (P3)
58. Hay 3 amigos para probar cada semana. (P4)

## Respuestas del 19/10 (preguntas 2)
59. La partida es larga: 5 turnos de guardia, cada uno con varios casos, y se guarda entre turnos (decisión 16). La duración exacta de cada turno se ajusta jugando. (preguntas 2 · 4)
60. La evidencia se entrega en el patrullero y cuenta en el momento. (preguntas 2 · 5)
61. Cristian trabaja solo. Él mergea y aprueba el arte. (preguntas 2 · 6)
62. No se usa Jira. Las tarjetas son issues de GitHub en el repo de BPD. (preguntas 2 · 7)
63. El código vive en la PC de Cristian (`D:\Dev\BPD`), con sesiones de Claude Code. (preguntas 2 · 8)
64. Primera meta (la eligió Claude): un allanamiento jugable de punta a punta con cajas grises (comisaría, patrullero, allanamiento, vuelta y cuota), de 1 a 4 jugadores por Steam con voz. (preguntas 2 · 9)
65. El repo es privado, `cristiangelini/BPD`. (preguntas 2 · 10)

## Allanamiento de la semana 1 (19/10)
66. Los casos no tienen tiempo límite. La presión la ponen los NPCs (en el allanamiento, el medidor de denuncia del abuelo). (allanamiento · 1)
67. El patrullero lo maneja un jugador, también en la semana 1; no hay viajes automáticos. (allanamiento · 2)
68. La voz es pulsar para hablar, con la opción de dejarla siempre abierta. (allanamiento · 3)
69. Allanamiento de la semana 1: sueldo de 500, cuota de 800 y multa de 20 por adorno roto. (allanamiento · 4)
70. El abuelo entra en la semana 1 como NPC de la casa. (allanamiento · 5)
71. Los modelos provisorios no son cajas grises: son low poly con caras planas y colores fuertes (decisión 12), hechos por código en `tools/modelgen`, para ver la jugabilidad y que se vea lindo. No son el arte final: el final lo aprueba Cristian y el arte de IA nunca es el final. (pedido de Cristian, 19/10)
72. Todos los personajes usan el mismo cuerpo "pera" (pesado abajo, sin piernas, zapatones, cabecita), elegido entre 5 estructuras. Los policías van todos con uniforme azul y los diferencia el color de la piel (rosa, naranja, lima y violeta). Los NPC se distinguen por ropa y accesorios (bigote, gorra, objetos) y tienen pieles más suaves, para que un policía siempre resalte. (pedido de Cristian, 19/10)
73. El policía mide 1,55 m de alto y 1 m de ancho (ojos a 1,35 m) para coincidir con el cuerpo pera, y las puertas y los pasillos miden 1,2 m de ancho. ([escala.md](escala.md), pedido de Cristian, 19/10)
