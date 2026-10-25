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
74. La casa del abuelo es el doble de grande: unos 24 × 20 m de planta y unos 14 ambientes. (pedido de Cristian, 19/10)
75. Cada caso tiene una historia bizarra que cuenta el comisario, con el porqué de cada cosa a buscar; vale para todo el juego. La del caso 1.1 es el bingo clandestino del abuelo ([investigacion.md](investigacion.md)). (pedido de Cristian, 19/10)
76. Los muebles se revisan con las manos: el policía agarra el cajón o la puerta y la abre tirando despacio (para atrás con S o de costado), no con un botón. Si se tira fuerte o con apuro, lo de adentro sale volando. (pedido de Cristian, 19/10)
77. El gato Michi y la vecina chismosa entran ya en la casa del abuelo. (pedido de Cristian, 19/10)
78. No hay meta semanal congelada: cada semana se avanza lo que se pueda. Las ideas que no se hacen ahora van al issue "Para después". Reemplaza la regla de una meta por semana. (pedido de Cristian, 19/10)
79. Cada allanamiento es un lugar más una historia, sorteados con la semilla. El comisario solo trae una denuncia anónima y los policías adivinan la historia con las pistas, entre 3 sospechas ([historias.md](historias.md)). (pedido de Cristian, 19/10)
80. Los allanamientos no son solo casas: hay comercios, empresas y edificios. Los 10 lugares son la casa del abuelo, la panadería, la peluquería de mascotas, la ferretería, la fábrica de muñecos, la oficina de seguros, el laboratorio de pasteles, el edificio de departamentos, el hotel y el gimnasio. (pedido de Cristian, 19/10)
81. La casa del abuelo tiene 6 historias: bingo clandestino, carreras de tortugas, la figurita del museo, dentaduras del geriátrico, radio pirata y club de lucha de jubilados ([historias.md](historias.md)). (pedido de Cristian, 19/10)
82. Se arma una ciudad abierta y navegable donde están todos los lugares de los casos. Cada caso pasa en un lugar distinto, con su propio personaje. Se arma de a poco, un lugar por vez, y se puede reestructurar después ([ciudad.md](ciudad.md)). (pedido de Cristian, 19/10)
83. El mapa de la ciudad es el triple de grande que el primer borrador (7 × 5 manzanas) y el turno termina al volver con la evidencia a la comisaría. Qué hay al entrar a cada lugar se decide después. (pedido de Cristian, 19/10)
84. La panadería es el segundo lugar: la panadera Marta atiende el local abierto, con clientes adentro, y tiene 6 historias (el anillo en el pan, el polvo para estornudar, la masa madre robada, las tortas de boda falsas, la lotería del pan y las palomas mensajeras) ([panaderia.md](panaderia.md)). (pedido de Cristian, 20/10)
85. La panadería no tiene balcón: arriba solo hay dos ventanas a la calle. Cada lugar tiene lo que tendría uno de verdad de ese tipo. (pedido de Cristian, 20/10)
86. La linterna se prende y se apaga con F en cualquier momento, aunque esté guardada en el cinturón ([herramientas.md](herramientas.md)). (pedido de Cristian, 20/10)
87. Con las esposas se puede esposar a cualquier persona o NPC del juego: compañeros, el dueño del lugar, clientes, vecinos y animales ([herramientas.md](herramientas.md)). (pedido de Cristian, 20/10)
88. La comisaría es la base de cada turno: se aparece en la sala de guardia, el comisario da el caso en su oficina, se retira el equipo en la armería y el turno termina al estacionar. Un caso por turno, caja común para los 4, sueldo de 500, cuota de 800 que sube 100 por turno (es una meta, no se paga), 5 turnos con "¡Ascendidos!" al final, y no llegar a la cuota termina la partida ("Suspendidos") hasta que exista la fuga. La armería empieza con el ariete, las herramientas del cinturón, donas, guantes de goma y carretilla ([comisaria.md](comisaria.md)). (Cristian aprobó las propuestas, 20/10)
89. El tercer lugar es la peluquería de mascotas "Pelito Feliz", con el peluquero Ramiro, perros sueltos, la señora del caniche como chismosa y 6 historias ([peluqueria.md](peluqueria.md)). (Cristian aprobó las propuestas, 20/10)
90. El cuarto tipo de caso es el interrogatorio: un sospechoso con los medidores de nervios y de abogado, acciones absurdas de policía bueno y malo (gritar por el micrófono cuenta), confesión a 100 de nervios por 500 y el abogado a 100 lo suelta, sin tiempo límite. Sale 1 de cada 3 turnos, en una sala de interrogatorio de película aparte (un ala detrás de la comisaría), con 10 sospechosos, y también se puede interrogar al dueño después de un allanamiento ([interrogatorio.md](interrogatorio.md)). (Cristian, 20/10)
91. El turno de interrogatorio tiene cuota propia de 500 (el sueldo de la confesión): confesar lo aprueba y que venga el abogado lo pierde. La cuota normal de la partida no se puede juntar con un solo sueldo ([interrogatorio.md](interrogatorio.md)). (Cristian, 20/10)
92. Tres sospechosos del interrogatorio: el influencer transmite en vivo y, si nadie hace de bueno, la transmisión le suma abogado; el segundo gemelo está en la celda del carcelero y hay que llevar la carpeta de una sala a la otra; el peligroso, si se suelta, corre por la comisaría y hay que agarrarlo entre dos, como la caja fuerte ([interrogatorio.md](interrogatorio.md)). (Cristian, 20/10)
93. Al dueño del allanamiento se lo escolta: con E sobre el dueño esposado camina despacio detrás del policía, quejándose (+20 de denuncia), y si llega al patrullero, el turno siguiente es su interrogatorio, que paga 500 más la mitad de la evidencia que quedó sin entregar ([interrogatorio.md](interrogatorio.md)). (Cristian, 20/10)
94. El segundo tipo de caso es la persecución: el sospechoso maneja solo por la ciudad y los 4 lo persiguen en el patrullero, cada asiento con su tarea fija (manejar, radio y mapa, pinchos y red, sirena y megáfono). Se gana frenándolo 3 s y esposándolo, y se pierde si se aleja demasiado (distancia a 100) o si pasa 1 minuto (excepción a la decisión 66, se mide jugando). Sueldo de 500. Los turnos 3, 6... siguen siendo interrogatorio y el resto se reparte mitad allanamiento y mitad persecución ([persecucion.md](persecucion.md)). (Cristian, 20/10)
95. La ciudad tiene una autopista en anillo alrededor, con 4 rampas y 2 peajes, donde el patrullero llega a 110 km/h; el club de golf queda afuera del anillo, del lado este. En el golf son dos ladrones y uno sale corriendo cuando los frenan; para la grúa hay un patrullero viejo detrás de la comisaría ([persecucion-lugares.md](persecucion-lugares.md)). (Cristian, 21/10)
96. La persecución es también el final de los casos en que el sospechoso se escapa: en el allanamiento, el dueño que ve a un policía levantar la evidencia principal (a menos de 15 m, sin esposas ni escolta, una vez por allanamiento) huye en lo suyo (el abuelo en la silla de ruedas, Marta y Ramiro en el auto de fuga); agarrado, cuenta como llevarse al dueño, y escapado, el caso se resuelve con la evidencia pero sin interrogatorio. En el interrogatorio, el peligroso que llega a la puerta de la calle se lleva el patrullero viejo: agarrado, el interrogatorio sigue, y escapado, se pierde ([persecucion-final.md](persecucion-final.md)). (Cristian, 21/10)
97. La escena del crimen (tipo 3) empieza con el pastel robado del concurso de la plaza: seis pasteleros parecidos, pistas físicas que descartan sospechosos, fichas con foto, huellas, dientes y pelo, y se acusa en el tablero con hilo rojo de la sala del tablero de la comisaría. Los sospechosos se cansan y se van de a uno. Acusado bien, el culpable a veces se entrega y pasa al interrogatorio y a veces sale corriendo y empieza una persecución ([escena-del-crimen.md](escena-del-crimen.md)). (Cristian, 21/10)
98. El quinto tipo de caso es el control de tránsito, empezando por "Hora pico": conos y barrera en una esquina, los autos de la ciudad paran de a uno, se revisan papeles y baúl, y el buscado se reconoce por las pistas del comisario y la radio. Sin tiempo límite, solo el medidor de paciencia de la fila; al segundo inocente detenido se pierde el caso; si el buscado pasa, arranca la persecución ([control-transito.md](control-transito.md)). (Cristian, 21/10)
99. El sexto tipo de caso es la fuga, empezando por "La llave en la dona": la primera vez que un turno no llega a la cuota, los 4 aparecen de noche presos en las celdas de su comisaría y tienen que llegar al patrullero mientras el guardia de noche se come sus donas (una tiene la llave). Hay una sola fuga por partida: si se escapan siguen con el turno siguiente sin la plata del turno fallado, y si el guardia los atrapa 3 veces, o fallan la cuota otra vez, termina con "Suspendidos" ([fuga.md](fuga.md)). (Cristian aprobó las propuestas, 22/10)
100. El séptimo tipo de caso es la infiltración, empezando por el Club de abuelos (después, Coro de iglesia): los 4 se disfrazan con las manos en el casillero de la comisaría (pelucas, bigotes y bastones que se ponen llevándolos a la cabeza y se caen si corren o se chocan), entran al club, juegan al bingo y bailan sin levantar sospechas mientras juntan 3 pruebas contra Doña Chela. Si los descubren, ella huye y arranca la persecución ([infiltracion.md](infiltracion.md)). (Cristian, 22/10)
101. La segunda variante de la infiltración es el Coro de iglesia: el Maestro Ernesto se queda con la colecta del órgano nuevo, los policías entran con túnica y cancionero, cantar se mide solo por el tiempo (cantar con la batuta arriba y callarse con la batuta abajo) y, si los descubren, él huye en la combi del coro con los coristas cantando adentro ([infiltracion-coro.md](infiltracion-coro.md)). (Cristian, 22/10)
102. El octavo tipo de caso es el robo a un banco en vivo, empezando por los ladrones con máscaras de animales (El Oso, el jefe, más el conejo, el chancho y el pato): llegan con el robo en marcha, uno negocia por teléfono con El Oso cumpliendo pedidos absurdos que frenan el taladro y sueltan rehenes, los otros entran por atrás o la ventilación, esposan ladrones y sacan rehenes. El taladro abre la bóveda a los 8 minutos y, si se abre, los ladrones huyen y arranca la persecución ([robo-banco.md](robo-banco.md)). Los pedidos de El Oso son donas, el feliz cumpleaños y llevar el patrullero lejos; si El Oso ya está detenido cuando se abre la bóveda, los demás se van con las bolsas sin persecución. (Cristian, 22/10)
103. El noveno tipo de caso es la protección de un político, empezando por el acto en la plaza: el diputado Pompeyo Lustre da un discurso de 6 minutos, cuatro vecinos le tiran huevos y tomates con física, los policías los paran con el cuerpo, encuentran y esposan a los que tiran y lo llevan de vuelta de la mano cuando se baja a saludar. Con 10 manchas en el traje se va furioso y el caso se pierde ([proteccion-politico.md](proteccion-politico.md)). (Cristian, 23/10)
104. El décimo tipo de caso es la cárcel, empezando por el motín en el comedor: la cárcel es un lugar nuevo de la ciudad (cuadra 5, 2, se llega en el patrullero) que usan los 10 casos de la cárcel; 20 presos con enojo que se contagia se tiran comida con física, los policías se cubren con bandejas y mesas volcadas, calman a los presos hablándoles o esposándolos y llevan a los 3 cabecillas a la celda de castigo. Con 15 presos enojados a la vez el motín se desborda y el caso se pierde ([carcel-motin.md](carcel-motin.md)). (Cristian, 23/10)
120. La segunda variante de la protección del político es la caminata por el mercado: el diputado Lustre recorre 12 puestos de un mercado techado y prueba todo; 3 platitos tienen laxante. Los policías prueban antes con el platito en la mano y la tecla de la dona (el que come uno malo tiene 40 s de retorcijones, que se cortan encerrándose 8 s en el baño químico), le sacan el plato o esposan al vendedor resentido. La primera vez que el diputado come uno malo corre al baño (30 s y 200 menos de sueldo); la segunda se va a su casa y el caso se pierde ([politico-mercado.md](politico-mercado.md)). (Cristian, 24/10)
121. (Propuesta, 24/10) La segunda variante del robo al banco es "Rehenes que no quieren irse": la misma banda y el mismo taladro, pero los rehenes están de fiesta, caminan a la mitad y vuelven a su lugar si los sueltan antes de la puerta, 2 de 8 avisan a los ladrones si ven a un policía y la comida los convence ([robo-banco-rehenes.md](robo-banco-rehenes.md)). Cristian (24/10): el rehén que sueltan antes de la puerta vuelve caminando a su lugar. Faltan las preguntas 2 y 3.
122. (Propuesta, 24/10) La tercera variante del robo al banco es "Ladrones abuelos": la misma banda de cuatro, pero jubilados con bastón y cárdigan que caminan a la mitad y con un taladro de 12 minutos; cuando ven a un policía se sacan la máscara y se sientan entre los rehenes, la abuela pata tira canicas en la entrada para que los policías que corren se resbalen, El Oso no oye (doble E en el teléfono) y huyen en andadores a motor ([robo-banco-abuelos.md](robo-banco-abuelos.md)). Cristian (25/10): sí a las preguntas 1 a 3.
123. (Propuesta, 25/10) La cuarta variante del robo al banco es "El ladrón arrepentido": la misma banda, pero uno de los tres de abajo (al azar, nunca El Oso) llora y quiere devolver todo; si un policía le habla sin que lo vean los otros, abre la puerta de atrás, desenchufa el taladro 60 s y saca dos rehenes, y si la banda lo ve ayudando lo ata a una silla hasta que un policía lo desata. Cada ayuda suma 50 al sueldo ([robo-banco-arrepentido.md](robo-banco-arrepentido.md)). Cristian (25/10): sí a las preguntas 1 a 3.
124. (Propuesta, 25/10) La quinta variante del robo al banco es "El ladrón es el gerente": en todos los robos al banco el señor Moneda, el gerente, espera en pijama al lado de su auto y le da al policía la llave de la puerta de atrás (esposarlo cuando es inocente cuesta 200); en esta variante es el jefe de la banda: la llave que da no abre, murmura por un walkie que acelera el taladro y su auto espera con el baúl abierto. Se gana con el gerente esposado y se pierde si se escapa en su auto ([robo-banco-gerente.md](robo-banco-gerente.md)). Cristian (25/10): sí a las preguntas 1 a 3.
125. (Propuesta, 25/10) La sexta variante del robo al banco es "La bóveda que se inunda": el taladro del pato pinchó un caño y el banco se llena de agua (0,2 m por minuto hasta 1 m) que frena a todos, policías, ladrones y rehenes; desde los 0,5 m el taladro mojado va a la mitad, desde los 0,6 m los rehenes se suben a los mostradores y solo bajan con un flotador de patito del patrullero o con el agua baja. Una llave de paso afuera atrás (E 8 s, o 4 s entre dos) corta el agua, y abrir la puerta de adelante la desagota con una ola. Se gana con El Oso esposado, +100 si cierran el agua antes de 1 m ([robo-banco-inundado.md](robo-banco-inundado.md)). Faltan las preguntas 1 a 3.
126. (Propuesta, 25/10) La séptima variante del robo al banco es "Robo por el techo": el sobrino de El Oso maneja desde la vereda de enfrente un helicóptero de juguete enorme que espera en el techo del banco; cuando la bóveda se abre se lleva las bolsas de a una (20 s por viaje) y al final a El Oso colgado de una soga, en una persecución contra el helicóptero que vuela bajito (el acompañante del patrullero lo agarra de la soga desde la ventanilla). Se sube al techo por la escalera de incendio; el helicóptero se puede agarrar entre dos y bajarlo, y esposar al sobrino lo hace caer (+100). Se gana con El Oso esposado ([robo-banco-techo.md](robo-banco-techo.md)). Faltan las preguntas 1 a 3.
