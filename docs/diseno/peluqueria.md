# BPD · La peluquería de mascotas "Pelito Feliz" (propuesta, 20/10)

Tercer lugar para allanar, después de la casa del abuelo y la panadería ([historias.md](historias.md),
[panaderia.md](panaderia.md)). Sigue la idea de lugar + historia (decisión 79): una denuncia anónima, 3 sospechas en la
planilla y una sola historia verdadera, sorteada con la semilla. Todo es **(propuesta)** hasta que Cristian lo apruebe.

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
2. Ramiro, el sillón de espera y el interrogatorio.
3. Los perros sueltos.
4. La señora del caniche.
5. Las 6 historias, un PR cada una.

## Preguntas para Cristian
1. ¿La peluquería de mascotas como tercer lugar, o preferís otro de los 8?
2. ¿Están bien Ramiro, los perros sueltos y las 6 historias?
