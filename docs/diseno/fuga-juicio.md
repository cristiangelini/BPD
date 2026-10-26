# La fuga: el juicio rápido (propuesta, 26/10)

Décima variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.10: "uno hace de abogado y los demás de
testigos falsos"). Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y de las otras ocho
([fuga-limpieza.md](fuga-limpieza.md), [fuga-perro.md](fuga-perro.md), [fuga-tunel.md](fuga-tunel.md),
[fuga-ventilacion.md](fuga-ventilacion.md), [fuga-basura.md](fuga-basura.md), [fuga-simulacro.md](fuga-simulacro.md),
[fuga-techo.md](fuga-techo.md), [fuga-soborno.md](fuga-soborno.md), decisiones 150 a 157): celdas con candado, una sola
fuga por partida, salir en el patrullero, "¡Fugados!" y perder a la tercera captura. Los números son **(propuesta)**
hasta probarlos jugando.

## La idea
Es de mañana. Para ahorrar papeles, la ciudad mandó a la jueza Bermúdez a hacer un juicio exprés ahí mismo, en la sala
de espera de la comisaría: un escritorio de jueza, un estrado y un banco. Si los declaran inocentes, salen caminando por
la puerta. La jueza tiene apuro ("Tengo otros doce juicios antes del almuerzo") y poca paciencia.

El plan: uno se hace pasar por abogado, los demás declaran como testigos de una coartada que no existe. El abogado es el
único que sabe la coartada; los testigos tienen que decir lo mismo sin haberla leído.

El chiste cooperativo: la coartada viaja de boca en boca (por la voz o por señas) y cada testigo la cuenta como puede.
"Estábamos rescatando un gato" se convierte en "un perro" y la jueza levanta una ceja.

## Cómo es
1. **Despertar:** los 4 en las celdas. El guardia de día abre las celdas para el juicio y lleva a todos al banco de la
   sala de espera. Aviso: "Juicio exprés. Alguien tiene que hacer de abogado... y nadie estudió derecho."
2. **El abogado:** en la caja de objetos perdidos, al lado del banco, hay un saco con corbata y un maletín. El primero
   que se pone el saco es el abogado y ve el expediente: la coartada de la semilla, una de 10 ("Estábamos en el
   cumpleaños de la abuela de un compañero", "Rescatando un gato de un árbol", "En la fila del banco", etc.), con sus
   tres detalles: dónde, con quién y a qué hora.
3. **Preparar a los testigos:** antes de que empiece, el abogado tiene 60 s para contarles la coartada (con la voz, o
   mostrándoles el expediente de cerca: lo ven 2 s). El guardia vigila el banco: si alguien se levanta y se va de la
   sala, es una captura.
4. **El juicio:** la jueza llama a cada testigo al estrado (E en el estrado para subir). Le hace 3 preguntas, una por
   detalle. En el estrado hay 3 carteles con respuestas; el testigo agarra uno y lo levanta (E). Una sola es la de la
   coartada; las otras dos son parecidas ("el gato" / "el perro" / "el loro").
5. **El abogado defiende:** una vez por testigo puede gritar "¡Objeción!" (E en la jueza) y esa pregunta no cuenta.
6. **Las contradicciones:** cada respuesta equivocada es una contradicción ("¿Un loro? El otro testigo dijo un gato.").
   A la tercera, la jueza los declara culpables: es una captura.
7. **El veredicto:** si todos los testigos terminaron con menos de 3 contradicciones, "¡Inocentes! Pueden irse." El
   guardia los deja salir; tienen que llegar al patrullero, a 25 m del estacionamiento: "¡Fugados!".
8. **La captura:** culpables, o alguien que se va de la sala antes del veredicto: todos a las celdas y un juicio nuevo
   con otra coartada (la jueza no se acuerda de ellos: "¿Ustedes otra vez? No, no los conozco."). A la tercera llama al
   comisario: "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- La coartada: 10 o más, cada una con 3 detalles y 2 respuestas parecidas por detalle, con `tr()`.
- El orden de los testigos y de las preguntas.
- En qué cartel está la respuesta buena.
- Las frases de la jueza: 10 o más preguntando, dudando y dando el veredicto.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento.
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66), salvo los 60 s para preparar a los testigos.
- Jugando solo, el policía es abogado y testigo a la vez: ve el expediente y declara él mismo (más fácil, pero la
  jueza hace 5 preguntas en vez de 3).

## Lo que se reusa
`JailbreakLevel` (celdas, capturas, salida, final, guardado y sorteo), `DrillGuard` (el guardia de día que abre las
celdas y camina), la sala de espera y su gente del simulacro (`WaitingPerson`) como público, los disfraces
(`DisguisePiece`) para el saco y la corbata. Nuevo: la jueza, el estrado, los carteles, el expediente y las coartadas.

## Online
Todo lo decide el anfitrión: quién es el abogado, la coartada, las preguntas, las respuestas y el veredicto. El
expediente solo se ve en la PC del abogado (o de quien lo mira de cerca). Los carteles van por `PropSync`; la jueza y
el estrado, por `NpcSync`; subir al estrado, levantar un cartel y objetar, por las acciones (`ActionSync`).

## Atajos del panel de pruebas (cuando exista)
- Empezar la fuga del juicio (`--jailbreak=trial`).
- Saltar al veredicto.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo en décimos (`--jailbreak=trial`), la mañana, el guardia que lleva a todos al banco, la caja con el saco,
   el abogado y el expediente con la coartada (modelos en `tools/modelgen`).
2. La jueza, el estrado, los carteles, las preguntas y las contradicciones.
3. La objeción, el veredicto, la salida, la captura con coartada nueva, jugar solo y online.

## Preguntas para Cristian
1. ¿La fuga sortea en décimos entre las diez variantes (el soborno solo si les queda plata)? **Recomiendo sí:** todas
   comparten celdas, salida y final.
2. ¿Uno es abogado (el que se pone el saco ve la coartada) y los otros declaran levantando uno de 3 carteles en el
   estrado? **Recomiendo sí:** obliga a contarse la coartada y da para el teléfono descompuesto.
3. ¿Tres contradicciones es culpables (una captura, con coartada nueva) y el abogado puede objetar una pregunta por
   testigo? **Recomiendo sí:** da margen para un error por testigo sin que sea fácil.

## Cómo quedó el paso 1
- `--jailbreak=trial` fuerza la variante. El sorteo es en décimos, y el soborno sigue saliendo solo si les queda plata.
- De día, con el guardia de día (`TrialGuard`) en su escritorio y la llave en el cinturón. A los 6 s dice "¡Arriba,
  que hay juicio!" y abre las dos celdas. Desde ahí, el lugar de los presos es la fila de adelante: las celdas y la
  sala de guardia con sus bancos. El que se va a la oficina, a la armería o a la calle está fuera de lugar y el guardia lo
  atrapa si lo ve. Hay 60 s para preparar a los testigos y después dice "De pie, que entra la jueza Bermúdez" (la jueza
  es el paso 2).
- Al lado del banco está la caja de objetos perdidos con el saco de abogado encima (`DisguisePiece` "lawyer_jacket",
  se pone como el abrigo del simulacro). Quien lo tiene puesto es el abogado y ve el expediente en su pantalla.
- La coartada (`TrialAlibi`) tiene 3 detalles: qué hacían, dónde y con quién. Cada uno sale de 10 grupos de 3 respuestas
  parecidas ("rescatando un gato" / "un perro" / "un loro"), así que salen coartadas absurdas como "estábamos
  aprendiendo a nadar, en la casa de la abuela, con la tía Porota". 90 respuestas con `tr()`.
- En una captura, el saco vuelve a la caja y el juicio siguiente tiene otra coartada.
- Modelos `disguise_lawyer_jacket` y `lost_found_box` en `tools/modelgen/models/trial.js`. 96 textos nuevos. Pruebas en
  `test_trial_lawyer.gd`. Fotos en `/mnt/project-files/juicio/`.
