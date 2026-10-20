# BPD · La peluquería de mascotas "Pelito Feliz" (20/10)

Tercer lugar para allanar, después de la casa del abuelo y la panadería ([historias.md](historias.md),
[panaderia.md](panaderia.md)). Sigue la idea de lugar + historia (decisión 79): una denuncia anónima, 3 sospechas en la
planilla y una sola historia verdadera, sorteada con la semilla. Cristian la aprobó como tercer lugar el 20/10 (decisión 87); los números siguen marcados
**(propuesta)** hasta probarlos jugando.

## El local
Una planta de unos 16 × 12 m, en la calle comercial, al lado de la panadería.

| Ambiente | Qué hay |
|---|---|
| **La recepción** | El mostrador con la caja, un sillón de espera, la vitrina de collares y moños, y la pared de fotos de "clientes felices". |
| **La sala de corte** | Dos mesas de peluquería con secadores de pie, las tijeras colgadas, estantes de champú y la bañera para perros. |
| **Las jaulas** | Una pared de 8 jaulas con perros esperando (algunas abiertas). |
| **El depósito** | Bolsas de alimento de 15 kg, toallas, cajas de champú y un freezer. |
| **El patio** | Atrás, con césped, una cucha grande y la puerta de atrás. |

- **Cómo se entra:** como la panadería, el local está **abierto**. Lo cerrado es la puerta del depósito ("Solo
  personal"). La llave está colgada en el collar de uno de los perros; también se puede entrar por el patio con el ariete.
- **Escondites:** unos 12. Por ejemplo: adentro de la bañera, en una jaula, en la cucha del patio, en el freezer,
  detrás de las bolsas de alimento, adentro del secador de pie, abajo del sillón y en la caja de toallas.
- **Lo frágil:** los **frascos de champú** de los estantes y la **vitrina de collares**. Cada uno que se rompe es una
  multa de 20 y le sube la denuncia al peluquero.

## El peluquero y los perros
- **Ramiro**, el peluquero, con delantal lleno de pelos y una tijera en la mano, cuerpo pera (decisión 72). Corta
  perros todo el tiempo y no se mueve de la mesa, salvo para perseguir a un perro suelto.
- **Los perros:** 6 sueltos por el local (los de las jaulas abiertas), de cuerpo pera chico. Siguen al policía que tiene
  algo en las manos, lo saltan y a veces se llevan cosas chicas en la boca y las esconden en la cucha del patio (como las
  palomas de la panadería). Si un policía pisa o choca a un perro, ladra y el peluquero suma denuncia (+5).
- **Su distracción:** el policía que se sienta en el sillón de espera con un perro en brazos (lo agarra y E en el sillón)
  tiene al peluquero contando la vida del perro 15 s, sin mirar lo que pasa en el local.
- **Interrogatorio (R):** como el abuelo, cada historia tiene sus frases y algo se le escapa.
- **La señora del caniche** hace el papel de la vecina: espera a su perro en la recepción y, si le alcanzan el caniche
  (está en una jaula), da una pista de la historia verdadera.

## Las historias
Cada una tiene una evidencia principal (sin ella no hay caso), 1 o 2 extras, un tipo de pista propio y algo que cambia en
el local. La denuncia anónima es siempre vaga: "en esa peluquería de perros pasa algo raro".

| Historia | Evidencia principal | Extras | Pista propia | Qué cambia |
|---|---|---|---|---|
| **El perro del millonario** | Duque, el galgo de un millonario, teñido de marrón (12 kg, 1500, se resiste) | La tintura (0,5 kg, 150), la carta pidiendo rescate (0,1 kg, 300) | Duque tiene raíces blancas: de cerca se le ve el color original | Hay 4 perros marrones iguales; Duque se escapa si lo sueltan |
| **El champú crecepelo** | El bidón del champú (8 kg, 1000) | La fórmula (0,1 kg, 300), un frasco de muestra (0,5 kg, 100) | Un perro de una jaula tiene pelo hasta el piso | Al que se moja con champú (la bañera gotea) le crece un bigote enorme por 30 s: no ve bien abajo |
| **El concurso arreglado** | La copa del concurso canino (3 kg, 1000) | Las fichas de los jurados (0,2 kg, 300), el peine de oro (0,2 kg, 200) | Todas las fotos de "clientes felices" tienen al mismo perro ganando | El perro campeón ladra fuerte cuando alguien se acerca a la copa |
| **Contrabando de huesos** | La bolsa de huesos de dinosaurio del museo (20 kg, 1200) | El mapa de la excavación (0,1 kg, 300) | Los perros cavan en el patio donde hay algo enterrado | Hay que cavar con la pala del patio; los perros cavan solos y desordenan |
| **El collar de diamantes** | El collar de una señora, puesto en un perro (0,2 kg, 1500) | El estuche (0,3 kg, 200) | Un perro brilla bajo la luz del secador | El perro que lo tiene se cambia de lugar cada 30 s; hay que atraparlo |
| **Peluquería de humanos clandestina** | El libro de turnos de los clientes humanos (0,3 kg, 1000) | La peluca (0,2 kg, 150), el espejo (4 kg, 200, frágil) | Hay pelos de humano entre los de perro (se ven distintos con la linterna) | Llegan clientes humanos a cortarse y el peluquero los tapa con toallas |

Los pesos y valores siguen la escala del bingo: la principal vale unos 1000 y los extras suman entre 300 y 600.

## Qué se reutiliza
- Lo compartido de las historias (historias.md): escondites sorteados, notas, huellas, 3 sospechas, la planilla, el
  patrullero y la pantalla del turno.
- De la panadería: el local abierto con NPC que atienden, la puerta "Solo personal", los clientes y el chismoso.
- De la casa del abuelo: los cajones y los ganchos de cada historia (StoryRig).

## Atajos del panel de pruebas
- Abrir la peluquería con una historia elegida (`--place=groomer --story=<id>`).
- Soltar o encerrar a todos los perros.

## El orden para hacerlo (un PR chico por paso)
1. El local en la ciudad, con los ambientes, los escondites y lo frágil.
   - **Cómo quedó (propuesta):** el local va en su lote de la calle comercial, al lado de la panadería, con el frente
     hacia la calle. Adelante, la recepción (mostrador con la caja, sillón de espera, vitrina de collares, fotos de
     clientes y un estante de champú) y la sala de corte (2 mesas con secador de pie, bañera y el estante grande de
     champú, con vidriera a la calle). Atrás, las jaulas (8, en dos filas, 2 abiertas) con la salida al patio, y el
     depósito (bolsas de alimento, freezer, caja de toallas). El patio tiene césped, una cerca baja que se puede saltar y
     la cucha grande. Cerrados: la puerta del depósito desde la sala de corte y su puerta de atrás al patio (se rompe
     con el ariete). 12 escondites, 6 para cosas pesadas. Lo frágil: 24 frascos de champú y 6 collares, 20 de multa
     cada uno. "Peluquería (prueba)" en el menú la abre. Capturas en `peluqueria/` de la carpeta del proyecto.
2. Ramiro, el sillón de espera y el interrogatorio.
   - **Cómo quedó (propuesta):** Ramiro (delantal rosa lleno de pelos, jopo, bigote y tijera) corta en la primera mesa
     y no se mueve de ahí. Llena la denuncia como Marta: 15 si lo empujan, 5 por puerta rota (la oye desde cualquier
     lado), 10 por cada frasco o collar que ve romperse (los de la recepción no los ve, hay una pared), 5 por pregunta,
     y llama al abogado en 100. Con R suelta 2 cosas por caso (cada historia le da las suyas; sin historia dice "Yo solo
     corto pelo, oficial") y después se ofende. **El sillón:** el policía que tiene un perro en brazos lo apunta y con E
     se sienta; Ramiro le cuenta la vida del perro 15 s y mientras tanto no ve nada de lo que se rompe. E otra vez se
     levanta antes. Después necesita 30 s para contar otra. Hasta que estén los perros (paso 3), cualquier cosa del
     grupo "dogs" cuenta como perro.
3. Los perros sueltos.
   - **Cómo quedó (propuesta):** 6 perros sueltos de 6 kg (uno los alza solo), de 6 colores, más 6 enjaulados que por
     ahora solo se ven. Pasean por la recepción, la sala de corte, las jaulas y el patio (el depósito no, está cerrado).
     Siguen al policía que tiene algo en la mano, a menos de 6 m, y lo saltan cada 2,5 s. Cada 12 s miran si hay algo
     chico (1 kg o menos) que un policía dejó en el piso y se lo llevan en la boca a la cucha; lo dejan apoyado, así lo
     frágil no se rompe, y si alguien se lo saca de la boca lo sueltan. Ladran si un policía los choca a más de 2,5 m/s
     o si caen fuerte (por ejemplo, al tirarlos), como mucho un ladrido cada 2 s, y cada ladrido le suma 5 a la
     denuncia de Ramiro. Alzado, un perro sirve para el sillón de espera. Ramiro todavía no sale a perseguirlos.
4. La señora del caniche.
   - **Cómo quedó (propuesta):** la señora (tapado lila, peinado alto y blanco, perlas y una carterita) espera parada en
     la recepción, al lado del sillón. Cada 10 s llama al policía que pasa a menos de 7 m ("¡Psst! ¡Oficial!"). Con E pide
     a Fifí, la caniche blanca del moño rosa, que espera en una jaula con rejas del fondo y no sale hasta que un policía
     la saca. Cuando le acercan a Fifí (alzada, soltada o tirada a menos de 1,3 m), la toma en brazos y cuenta lo que vio:
     la pista de la historia verdadera, que pone cada historia en el paso 5 (hasta entonces dice que no vio nada raro).
     Con E después repite la pista. Los otros perros no le sirven.
5. Las 6 historias, un PR cada una.
   - **Cómo quedó el caso (propuesta):** la peluquería ya es un caso como la panadería: el comisario da la denuncia en
     la comisaría, hay 3 sospechas sorteadas entre las 6 historias (con su nota cada una), la planilla con Q, la barra
     de denuncia de Ramiro, multas por lo que se rompe, el patrullero y la pantalla del turno. Ramiro suelta dónde
     escondió 2 cosas de la historia y la señora, cuando recibe a Fifí, cuenta dónde lo vio esconder otra. Si Ramiro
     llama al abogado se pierde el caso. Todavía no sale al tocar "Jugar" (se abre con el botón de prueba): entra al
     sorteo cuando tenga más historias.
   - **El concurso arreglado (propuesta):** Bizcocho, el perro marrón con escarapela azul, gana siempre el concurso
     del barrio porque Ramiro les regaló un peine de oro a los jurados. La copa (3 kg, 1000) va en un escondite grande;
     las fichas de los jurados (300) y el peine de oro (200) en cualquiera. Su pista: 3 fotos de "clientes felices" (en
     el mostrador, en la segunda mesa y arriba de las jaulas) con Bizcocho y la copa. Bizcocho no se aleja de su copa y
     ladra fuerte ("¡GUAU! ¡GUAU!") cada 3 s si un policía está a menos de 2,5 m de ella: cada ladrido son 5 de
     denuncia. Alzado no ladra, así que uno lo agarra mientras otro saca la copa. Capturas: `concurso_*.png`.
   - **El collar de diamantes (propuesta):** a la señora Rosales le robaron el collar y Ramiro se lo puso a uno de los
     perros sueltos (sorteado con la semilla). Ese perro no sigue a nadie: escapa de los policías que se le acercan a
     menos de 3 m, 1,7 veces más rápido que los otros, y cada 30 s se va a otro lado (los dos secadores, la recepción, las
     jaulas y el patio), así que hay que acorralarlo entre varios. Bajo la luz del secador el collar brilla: el policía
     que lo ve a menos de 5 m suma la pista. Agarrar el collar se lo saca al perro. El estuche (0,3 kg, 200) va
     escondido. Captura: `collar_*.png`.

## Preguntas para Cristian (respondidas el 20/10: sí a las dos)
1. ¿La peluquería de mascotas como tercer lugar, o preferís otro de los 8?
2. ¿Están bien Ramiro, los perros sueltos y las 6 historias?
