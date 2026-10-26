# BPD · Robo a un banco: El banco del pueblo (propuesta, 25/10)

Octava variante del robo a un banco en vivo ([casos.md](casos.md), 10.3), sobre la base de los ladrones con máscaras
de animales ([robo-banco.md](robo-banco.md), decisión 102), junto a la fiesta ([robo-banco-rehenes.md](robo-banco-rehenes.md),
121), los abuelos ([robo-banco-abuelos.md](robo-banco-abuelos.md), 122), el arrepentido
([robo-banco-arrepentido.md](robo-banco-arrepentido.md), 123), el gerente ([robo-banco-gerente.md](robo-banco-gerente.md),
124), la bóveda que se inunda ([robo-banco-inundado.md](robo-banco-inundado.md), 125) y el robo por el techo
([robo-banco-techo.md](robo-banco-techo.md), 126). Todos los números son **(propuesta)** hasta probarlos jugando. La
decisión de esta variante es la 127, de las que quedan del hilo A.

## La idea
No es el banco grande del barrio: es el Banco del Pueblo, una sucursal chiquita con un solo mostrador de madera, una
planta y un solo empleado, don Plácido, que duerme la siesta sobre el mostrador. Y la banda tampoco es la de siempre:
es un solo ladrón, El Conejo, que se animó a robar solo y está muerto de nervios. Él mismo sostiene el taladro de la
bóveda, y cada ruido lo hace saltar. El chiste cooperativo: todo se hace en silencio. Hay que entrar agachados,
sacarle la llave del bolsillo a don Plácido sin despertarlo y llevárselo dormido entre dos, mientras el que maneja
no toca la sirena. Si don Plácido se despierta, grita "¡Ladrones!" y El Conejo se pone más nervioso; si El Conejo
llega al límite, sale corriendo con lo que tenga.

## La historia del comisario
"¡Novatos! ¡Roban el Banco del Pueblo! Sí, ese chiquito. Parece que hay un solo ladrón... y un solo empleado, que
duerme. Despacito, que el ladrón está nervioso."

## Cómo es el caso
1. **El banco chico:** el mismo edificio del robo base, pero una pared de estantes con frascos y biblioratos corta el
   hall por la mitad: queda un hall chico con un mostrador de madera, una planta y un cartel pintado a mano ("Banco
   del Pueblo"). La oficina del gerente está cerrada (no hay gerente: el señor Moneda no está) y la camioneta de la
   banda espera en la vereda, como siempre.
2. **Don Plácido:** duerme sobre el mostrador con la cabeza en los brazos y ronca ("Zzz..."). Es el único rehén: no
   hay nadie más en el piso. En el bolsillo del chaleco tiene la llave de la puerta de atrás: un policía agachado se
   la saca con E sin despertarlo (parado o corriendo, se despierta).
3. **El ruido:** lo despierta un policía que corre a menos de 4 m, la sirena del patrullero a menos de 20 m del banco,
   una cosa que se cae cerca (más de 4 m/s, a menos de 4 m) o un policía que le habla. Despierto, se para, grita
   "¡Ladrones! ¡Ladrones!" durante 6 s y se vuelve a dormir sentado, más profundo. Cada vez que grita, El Conejo se
   pone más nervioso (ver pregunta 2).
4. **Sacarlo dormido:** dormido se lo carga entre dos (pesa 70 kg, como la caja fuerte: uno solo lo arrastra) hasta
   la vereda, donde se despierta, bosteza y se va a su casa. Si se despierta mientras lo llevan, se suelta de golpe y
   se queda parado ahí, gritando.
5. **El Conejo:** solo, con la máscara de conejo, sostiene el taladro de la bóveda. Tiene un medidor de nervios de 0 a
   100 que se ve arriba de la cabeza (las orejas tiemblan más). Sube 10 con cada ruido que oye (los mismos de don
   Plácido, a 8 m), 20 con cada grito de don Plácido y 30 si ve a un policía. Baja 2 por segundo en silencio. Con 50
   o más suelta el taladro y va a espiar la puerta (el taladro se para mientras espía, 8 s). Con 100 se le acaban los
   nervios: sale corriendo a la camioneta con las bolsas que tenga (ninguna si la bóveda está cerrada) y arranca la
   persecución de siempre (ver pregunta 3).
6. **El taladro:** el de la base, pero solo avanza cuando El Conejo lo sostiene. Tarda 6 minutos en abrir (es una
   bóveda chica). Cuando la abre, El Conejo carga 2 bolsas y huye en la camioneta, como en la base.
7. **Esposar:** de atrás, como siempre. De frente, El Conejo se asusta tanto que se rinde solo (como el conejo de la
   base), pero el susto le suma 30 a los nervios: si ya estaba en 70 o más, en vez de rendirse sale corriendo.
8. **El teléfono:** atiende El Conejo, temblando. Sus pedidos son chicos (un vaso de agua, que alguien le diga que todo
   va a salir bien, una zanahoria). Cada pedido cumplido le baja 30 los nervios y frena el taladro 30 s, como en la
   base. Mentirle le sube 20.
9. **Se gana** con El Conejo esposado. Sueldo de 700: 300 menos si don Plácido queda adentro cuando El Conejo huye y
   50 menos por cada bolsa que se lleve; +100 si don Plácido no se despertó nunca. Cuota de 400. **Se pierde** si El
   Conejo se escapa en la persecución.

## Lo que se reusa
Todo el banco del robo base, el conejo de la banda (modelo, esposas que se rinde y escolta con OwnerEscort), el
taladro, el teléfono, las cosas que se cargan entre dos (como la caja fuerte), la camioneta y la persecución embebida
(ChaseCase.begin). El agacharse del policía (Cop.is_crouching) y la sirena del patrullero. Lo nuevo: la pared de
estantes y el mostrador de madera, don Plácido dormido (un cuerpo que se agarra) y el medidor de nervios de El Conejo.

## El orden para hacerlo (un PR chico por paso)
1. El banco chico (pared de estantes, mostrador de madera, cartel), don Plácido dormido sobre el mostrador y El Conejo
   solo en el taladro; sin los otros ladrones, sin rehenes en el piso y sin gerente. El sorteo pasa a octavos (sorteado
   antes que todos, las semillas 1 a 4 no cambian); `--bank=town` lo fuerza.
2. Don Plácido: el ruido que lo despierta (correr, la sirena, cosas que caen, hablarle), su grito, la llave que se saca
   agachado y llevárselo dormido entre dos hasta la vereda.
3. Los nervios de El Conejo: el medidor, el taladro que solo avanza si lo sostiene, ir a espiar con 50, salir
   corriendo con 100, el susto al esposarlo de frente y el teléfono que lo calma.
4. El caso: radio, planilla, sueldo, cuota y la huida a la camioneta.
5. El online.

## Preguntas para Cristian
1. **¿El banco del pueblo tiene un solo ladrón, El Conejo, en vez de la banda de cuatro?** Recomendado: sí, como dice
   la tabla de [robo-banco.md](robo-banco.md) ("un solo ladrón muy nervioso"); cambia el caso de pelear contra la
   banda a hacerlo en silencio. La otra opción es la banda de siempre en un banco chico.
2. **¿Don Plácido se despierta con el ruido (correr cerca, la sirena, cosas que caen) y su grito pone nervioso al
   ladrón, y se lo saca dormido entre dos?** Recomendado: sí, con +100 si no se despierta nunca. La otra opción es
   que no se despierte nunca y se lo saque de la mano como a los rehenes de la base.
3. **¿Con los nervios en 100 El Conejo sale corriendo a la camioneta aunque la bóveda siga cerrada?** Recomendado:
   sí, sin bolsas: se puede perder igual si se escapa, pero sin plata. La otra opción es que los nervios solo lo
   frenen (espía más) y nunca huya antes de que se abra la bóveda.

## Hecho así

- **Paso 1 (el banco chico, don Plácido y El Conejo):** un octavo de las semillas, sorteado antes que todos
  (`hash(["bank pueblo", semilla]) % 8`), es el banco del pueblo; las semillas 1 a 4 de las pruebas viejas no cambian
  y `--bank=town` lo fuerza. Una pared de madera con estantes de frascos de mermelada y biblioratos va de la pared del
  fondo a la fachada en x = -1 y deja un hall chico sin la fila de postes; el cartel dice "Banco del Pueblo". El
  señor Moneda y su auto no están. No hay rehenes en el piso: solo don Plácido (`BankClerk`), dormido en su banquito
  detrás del mostrador, inclinado hacia adelante, con "Zzz..." arriba de la cabeza y la llave asomando del bolsillo
  del chaleco. Pesa 70 kg y espera quieto en su banquito hasta que un policía lo agarra. El Conejo está solo, en el
  lugar del pato al lado del taladro, y como está solo es el jefe. Capturas en `/mnt/project-files/pueblo/paso1-*.png`.
- **Paso 2 (don Plácido y el ruido):** lo despierta un policía que corre a menos de 4 m, la sirena del patrullero a
  menos de 20 m, algo que se mueve a 4 m/s o más a menos de 4 m (mira cada 0,2 s) o un policía que le habla con E
  parado. Despierto se endereza y grita una de tres frases ("¡Ladrones! ¡Ladrones!") durante 6 s, y se vuelve a
  dormir; si lo estaban cargando, se suelta de las manos de todos. Agachado, E le saca la llave del bolsillo sin
  despertarlo (el policía queda con la llave de la puerta de atrás). No se cae: carga o suelto, queda parado. Afuera
  del banco bosteza ("¿Ya es la hora de cerrar? Me voy a casa.") y a los 4 s se va. El grito todavía no hace nada en
  El Conejo: eso es el paso 3. Capturas en `/mnt/project-files/pueblo/paso2-*.png`.
- **Paso 3 (los nervios de El Conejo):** una barra arriba de su cabeza (de verde a rojo, `BankNerves`). Sube 10 si
  oye ruido a menos de 8 m (un policía corriendo, la sirena a menos de 20 m, algo que cae fuerte; escucha una vez por
  segundo), 20 cada vez que grita don Plácido y 30 si ve a un policía; baja 2 por segundo. Una promesa cumplida en el
  teléfono le baja 30 y una mentira le sube 20 (los pedidos todavía son los de la base: eso se cambia en el paso 4).
  Con 50 o más se da vuelta a espiar la puerta del pasillo 8 s ("¿Hola? ¿Hay alguien?") y el taladro se para; después
  vuelve al taladro al menos 6 s antes de espiar otra vez. Con 100 sale corriendo por el pasillo, el hueco del
  mostrador y la entrada hasta la camioneta ("¡No puedo más!"). Si ve a un policía se rinde como el conejo de la base,
  salvo que ya tenga 70 o más: entonces sale corriendo. El taladro del banco del pueblo tarda 6 minutos. Capturas en
  `/mnt/project-files/pueblo/paso3-*.png`.
- **Paso 4 (el caso):** la radio pide silencio ("Despacito y sin sirena... Agáchense para sacarle la llave"). En el
  teléfono atiende El Conejo, tartamudeando: los tres pedidos de siempre (donas, que le canten algo, llevarse el
  patrullero) dichos con sus palabras, para calmarse. La planilla pide sacar a don Plácido, esposar a El Conejo y
  volver con él, el extra de sacarlo sin que se despierte (+100) y muestra sus nervios. Cuando se queda sin nervios
  nadie sostiene el taladro (se para del todo), y cuando llega a la camioneta arranca la persecución sin bolsas (a pie
  si está encerrada, con el modelo del conejo). Si la bóveda se abre antes, se lleva 2 bolsas. Si don Plácido sigue
  adentro cuando El Conejo se escapa, son 300 menos. El Conejo detenido va al interrogatorio del turno siguiente
  (sospechoso nuevo, con su confesión y sus tres frases que se le escapan). Capturas en
  `/mnt/project-files/pueblo/paso4-*.png`.
- **Paso 5 (el online):** el banco del anfitrión decide todo y los demás lo ven igual: don Plácido dormido o gritando,
  su globo, la llave en el bolsillo, si salió y si se fue a su casa (PropSync lo mueve), y la barra de nervios de El
  Conejo y su huida (NpcSync lo mueve). Un invitado agachado le saca la llave en la PC del anfitrión, y un invitado
  que corre cerca de don Plácido o de El Conejo hace el mismo ruido allá (el policía de cada PC manda también si
  corre).
