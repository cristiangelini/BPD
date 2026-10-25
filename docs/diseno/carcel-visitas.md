# BPD · Cárcel: día de visitas (propuesta, 25/10)

Variante 3 de la cárcel ([carcel-motin.md](carcel-motin.md), tabla de variantes; [casos.md](casos.md), 6.3). Usa la
cárcel de la cuadra (5, 2) del motín y del corte de luz. Decisiones 141 a 149. Todo es **(propuesta)** hasta que
Cristian responda las preguntas de abajo y se pruebe jugando.

## La idea
Es domingo de visitas y los guardias se fueron a un asado: los 4 novatos tienen que revisar a los visitantes en la
puerta y cuidar el comedor durante la visita. Las abuelas, los primos y las novias traen tortas, guitarras y pollos
asados, y adentro de muchos hay algo escondido para escaparse: una lima, una llave, una soga. El chiste: **se revisa
con las manos**, y abrir una torta que no tenía nada hace llorar a la abuela.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, hoy es día de visitas y los guardias tienen franco. Revisen
   todo lo que entra. Todo. Pero con cariño, que son las abuelitas".
2. **La fila:** al llegar, 8 visitantes (modelos nuevos: abuela, abuelo, mamá, novia, primo, tío, vecino, señora con
   cochecito) hacen fila en el patio, desde el portón hasta la **mesa de requisa** en la puerta del comedor. Cada uno
   trae una cosa en la mano. Pasan de a uno: el primero de la fila espera en la mesa hasta que un policía le dice que
   pase (E sobre él, "Adelante"). Si nadie lo atiende en 40 s, pasa solo, quejándose ("Bueno, paso yo").
3. **Revisar a la persona:** E sobre el visitante en la mesa y quedarse al lado 2 s lo **cachea** (como desatar al
   ladrón arrepentido): si tiene algo en los bolsillos o en los zapatos, cae a la mesa. Cachear no rompe nada.
4. **Revisar lo que trae:** lo que trae en la mano lo deja en la mesa al llegar. Se agarra (es un objeto con física) y
   E con él en la mano lo **abre**: la torta se parte, el pan se rompe, la guitarra se destapa. Si tenía algo, sale y
   queda en la mano del policía: se tira al tacho de la mesa (o al patrullero) y cuenta como confiscado. Si no tenía
   nada, queda roto: el visitante llora ("¡Mi torta de cumpleaños!") y resta en el sueldo. Lo que no se abrió se le
   devuelve al visitante cuando pasa.
5. **Lo escondido (al menos 12 juntadas al azar):** la lima en la torta de la abuela, la llave en el pan casero, el
   serrucho en la guitarra del primo, el mapa de la cárcel en el ramo de flores, la bufanda tejida que es una soga de
   10 m, el bebé del cochecito que es un muñeco lleno de herramientas, las ganzúas en el pollo asado, la paloma
   mensajera en el sombrero, el celular en la sandía, la pala plegable en la suela del zapatón, la cuchara de cavar en
   el ovillo de lana, el disfraz de guardia doblado adentro de un libro. Cada visitante trae una de esas cosas con la
   semilla, y de 4 a 6 de los 8 tienen algo escondido (en la cosa o en el bolsillo). Los demás traen lo mismo pero
   de verdad.
6. **Las pistas:** el que esconde algo se delata un poco: mira la cosa cada tanto, silba de nervios, la torta suena a
   metal al apoyarla ("clonc"), la sandía pesa el doble. No siempre, y los inocentes también tienen tics (la abuela
   nerviosa porque es su primera visita). Así se puede adivinar sin abrir todo.
7. **La hora de visita:** los que pasaron se sientan en las mesas del comedor frente a su preso (8 presos con mameluco
   naranja, el modelo del motín). La visita dura 6 minutos desde que pasa el último. El que todavía tiene algo
   escondido intenta **el pase por debajo de la mesa**: cada 20 a 40 s, si ningún policía mira su mesa (cono de la
   mirada de 60° y 10 m, como el guardia de la fuga al revés), mete las manos abajo de la mesa 3 s ("Psst, toma").
   Un policía que lo ve en esos 3 s y hace E sobre el visitante lo frena y le saca la cosa. Si termina, el preso la
   esconde en el mameluco y ya llegó.
8. **Lo que llega:** cada cosa que llega a un preso se ve al final: el preso sale con la lima, la soga o el disfraz de
   guardia y se va caminando muy tranquilo por el portón ("Chau, gracias por la visita"). **Con 3 cosas que llegan a
   los presos se pierde el caso.**
9. **El final:** a los 6 minutos de visita suena el timbre, los visitantes se despiden llorando y se van por el
   portón. El caso termina cuando se fue el último.
10. **El sueldo:** 600, 75 menos por cada cosa que llegó a un preso, 25 menos por cada cosa inocente rota, 25 más por
    cada cosa frenada en el pase por debajo de la mesa (la más difícil). Cuota propia de 400, como las otras cárceles.

## Lo que cambia con la semilla
Quiénes vienen (8 de los modelos de visitante), qué trae cada uno, quiénes esconden algo y dónde (en la cosa o en el
bolsillo), los tics de cada uno, en qué mesa se sienta cada uno y cuándo intenta el pase. Así no hay dos días de
visitas iguales.

## Lo que se reusa
- La cárcel, el comedor con sus 6 mesas, el portón y el patio (`PrisonLevel`).
- Los presos del motín (`PrisonInmate`, modelo `npc_preso`), sentados como al empezar el motín.
- Los objetos con física que se agarran (`Grabbable`) y E con algo en la mano (la dona que se parte de la fuga).
- E y quedarse al lado (desatar al ladrón arrepentido) para cachear.
- El cono de la mirada del guardia de la fuga, al revés: acá miran los policías.
- Lo nuevo: los 8 visitantes y sus modelos, la fila y la mesa de requisa, las cosas que se abren y se rompen, lo
  escondido, los tics, el pase por debajo de la mesa.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. La fila: `--prison=visits`, los 8 visitantes con sus modelos y lo que traen, la fila en el patio, la mesa de
   requisa y E para que pase el primero.
3. Revisar: cachear (E y quedarse 2 s), abrir lo que traen (E en la mano), lo escondido (12 cosas), confiscar y
   romper lo inocente.
4. Las pistas: los tics de los que esconden y de los inocentes, el "clonc" y el peso.
5. La hora de visita: sentarse frente a su preso, el pase por debajo de la mesa, frenarlo, y los que se van al final.
6. El caso: el comisario, la planilla, el sueldo, la cuota, perder con 3 y el sorteo en Jugar (`PlaceDraw.PRISONS`,
   en cuartos con el motín, el traslado y el corte de luz).
7. Online: la fila, lo abierto y lo roto, los tics, los pases y el final.

## Preguntas para Cristian
1. **¿Dos partes: la requisa en la puerta y después la hora de visita**, donde intentan pasar lo escondido por debajo
   de la mesa cuando nadie mira? Recomendado: sí, así hay algo que hacer en las dos mitades y el que se escapó de la
   requisa todavía se puede frenar.
2. **¿Abrir algo inocente lo rompe y resta 25** (la abuela llora por su torta)? Recomendado: sí, si no conviene abrir
   todo y las pistas no sirven.
3. **¿Se pierde con 3 cosas que llegan a los presos?** Recomendado: sí, con 4 a 6 escondidas tiene que ser posible
   perder, y 3 deja margen para un par de errores.

## Hecho así
- **Paso 2 (la fila):** `--place=visits` abre `scenes/levels/prison_visits.tscn`, la cárcel de día con
  `variant = "visits"`. `VisitPlan` pone 8 visitantes (`PrisonVisitor`, con los cuerpos de la abuela, el abuelo, la
  señora, la clienta, el cliente, el portero, el mudancero y la vecina) en fila en el patio, de la mesa de requisa
  (junto a la puerta oeste del comedor) hacia el portón, un lugar cada 1 m. Cada uno trae en la mano una cosa
  distinta de las 12 (`VisitItem`: torta, pan, guitarra, flores, bufanda, bebé, pollo, sombrero, sandía, zapatón,
  ovillo y libro, hechas con piezas por código), y la semilla elige de 4 a 6 que esconden algo (uno de cada 3 en el
  bolsillo, los demás adentro de la cosa; se encuentra en el paso 3). Nadie se mueve hasta que el primer policía
  cruza el portón. El primero camina a la mesa, deja su cosa arriba y saluda; E sobre él ("que pase") lo hace pasar
  y se lleva su cosa si sigue en la mesa (si la tiene un policía, protesta: "¿Y lo mío?"). Si en 40 s nadie lo
  atiende, pasa solo. La fila avanza un lugar y cada uno se sienta en su lugar del comedor, del lado de adelante de
  una mesa. Capturas en `/mnt/project-files/dia-de-visitas/`: `paso2-fila.png`, `paso2-mesa.png` y
  `paso2-sentado.png`.
- **Paso 3 (revisar):** en la mesa, R sobre el visitante y quedarse cerca (2,4 m) 2 s lo cachea ("¡Ay, cosquillas!"):
  lo que tenía en el bolsillo (lima, llave, ganzúas o mapa) cae a la mesa. Cachear no rompe nada y se hace una vez;
  después E lo deja pasar. Su cosa se agarra de la mesa y E con ella en la mano la abre (las piezas se desarman): lo
  escondido (`Contraband`, una de 12 cosas, cada una con su escondite: la lima en la torta, la paloma en el sombrero,
  la soga que era la bufanda...) queda en la mano del policía y cuenta como confiscado (`VisitPlan.confiscated`); si no
  había nada, el visitante llora y cuenta como roto (`VisitPlan.broken`). Lo abierto se queda en la mesa. Lo que no se
  encontró entra con el visitante (`PrisonVisitor.has_contraband`, para el pase del paso 5). Por ahora encontrar ya
  es confiscar: no hace falta tirarlo a un tacho. Capturas: `paso3-cacheo.png` y `paso3-abierto.png`.
- **Paso 4 (las pistas):** en la fila y en la mesa, el que esconde algo se delata cada 8 a 14 s: mira de reojo lo que
  trajo, silba ("Fiu, fiu... Nada raro por acá") o suda ("Qué calor hace, ¿no?"). Uno de cada 3 inocentes está nervioso
  igual y cada 15 a 25 s lo dice ("Es mi primera visita, estoy tan nerviosa..."), así que el tic solo no alcanza.
  Lo que trae, con algo adentro, pesa 1,6 veces más; si es de metal (lima, llave, serrucho, herramientas, ganzúas,
  pala, cuchara) suena "¡Clonc!" al dejarlo en la mesa; la paloma del sombrero hace "Currucucú" y el celular de la
  sandía vibra cada 9 a 15 s hasta que los encuentran. El mapa, la soga y el disfraz no hacen ruido: son los difíciles.
  Captura: `paso4-pistas.png`.
- **Paso 5 (la hora de visita):** frente al lugar de cada visitante, del otro lado de la mesa, está sentado su preso
  (`VisitInmate`, el modelo del motín). Cuando entra el último visitante empieza la visita: 6 minutos. El que todavía
  esconde algo (en el bolsillo o en lo que entró) intenta el pase cada 20 a 40 s: si ningún policía mira su mesa
  (10 m y 60° de donde mira la cámara) mete las manos abajo 3 s ("Psst... toma, rápido, por abajo"); si lo miran,
  espera 5 s y prueba de nuevo. E sobre él mientras pasa lo frena y se le saca (cuenta como confiscado y como pase
  frenado). Si termina, el preso lo guarda en el mameluco y cuenta como pasado (`VisitPlan.passed`). Al terminar la
  visita suena el timbre: los visitantes se van por el portón y los presos que recibieron algo se levantan y se van
  caminando con eso ("Gracias por la visita"). El día termina cuando se fue el último visitante. Captura:
  `paso5-pase.png`.
- **Paso 6 (el caso):** el comisario lo cuenta en su oficina en tres partes (los guardias de franco, cachear con R y
  abrir con E sin romper lo inocente, mirar las mesas durante la visita) y Q abre la planilla (`VisitCase`):
  visitantes que pasaron, el reloj de la visita, lo confiscado, los regalos inocentes rotos, lo que llegó a los
  presos y el extra de los pases frenados. Cuando se va el último visitante se gana: sueldo de 600, 75 menos por cada
  cosa que llegó a un preso, 25 menos por cada cosa inocente rota y 25 más por cada pase frenado. Cuota propia de 400.
  Con 3 cosas que llegan se pierde. En el sorteo de Jugar sale en un cuarto de los casos de la cárcel
  (`PlaceDraw.PRISONS`, con el motín, el traslado y el corte de luz). Captura: `paso6-planilla.png`.
