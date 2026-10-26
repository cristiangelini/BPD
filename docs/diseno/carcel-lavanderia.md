# BPD · Cárcel: la lavandería (25/10)

Variante 6 de la cárcel ([carcel-motin.md](carcel-motin.md), tabla de variantes; [casos.md](casos.md), 6.6). Usa la
cárcel de la cuadra (5, 2) del motín, del corte de luz y del día de visitas. Decisión 142. Cristian respondió
sí a las 3 preguntas (25/10); los números siguen **(propuesta)** hasta que se pruebe jugando.

## La idea
Es día de ropa sucia. Los presos trabajan en la lavandería, y cada tanto llega al portón el camión de la lavandería
de afuera a buscar los carritos de sábanas. Algunos presos se meten adentro de un carrito, abajo de la ropa, y otro
preso lo empuja muy tranquilo hasta el camión. Los novatos tienen que revisar los carritos antes de que suban. El
chiste: **se revisa metiendo las manos en la ropa sucia**, y en el camión no espera nadie.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, hoy la cárcel lava la ropa. El camión de la lavandería se lleva
   los carritos. Que se lleve sábanas, no presos".
2. **La lavandería:** la cocina del motín se vuelve lavandería: las ollas se cambian por 4 lavarropas y 2 secarropas
   contra la pared del fondo, una mesa de doblar y una soga con ropa colgada. Hay 6 presos trabajando (el modelo del
   motín con mameluco naranja), que doblan, cargan los lavarropas y llenan **carritos de ropa** (objeto con física y
   con ruedas, que también se puede empujar a mano). Nadie se mueve hasta que el primer policía cruza el portón.
3. **El camión:** llega al portón 4 veces, cada 2 minutos, y en cada vuelta se lleva 3 carritos (12 en total). Cuando
   llega toca bocina, y 3 presos empujan un carrito cada uno: salen de la lavandería por la puerta de la cocina,
   cruzan el comedor y el patio, y lo suben al camión por la rampa. Un carrito que entra al camión ya se fue.
4. **Los escondidos:** de los 12 carritos, de 4 a 6 llevan un preso abajo de la ropa (la semilla elige cuáles y en qué
   vuelta salen). Los demás llevan solo sábanas, toallas y medias.
5. **Revisar un carrito:** E sobre el carrito y quedarse al lado 1,5 s mete las manos en la ropa ("Puaj, está
   mojado"). Si hay alguien, salta para afuera ("¡Sorpresa!") y sale corriendo para el portón. Volcar el carrito de
   un empujón fuerte (correr contra él) también lo revisa: se cae la ropa y el escondido queda a la vista. Revisar un
   carrito sin nadie no resta, solo cuesta tiempo: el camión no espera.
6. **Atraparlo:** el que salta se esposa como cualquier sospechoso y se lleva del brazo a la celda de castigo (lo del
   corte de luz). Si llega al portón antes, se sube al camión y cuenta como escapado. Esposado y sin llevar, a los
   20 s se suelta y vuelve a correr.
7. **Las pistas:** el carrito con alguien se delata un poco: estornuda ("¡Achís!"), se le asoma un pie, pesa más (el
   que lo empuja va más lento y resopla), o el que lo empuja silba de nervios y saluda a los policías demasiado. Pero
   en uno de cada 3 carritos sin nadie hay un gato durmiendo en las toallas que también se mueve y maúlla, así que la
   pista sola no alcanza.
8. **La vuelta de tuerca:** cada tanto un preso de la lavandería se mete en un lavarropas o en el secarropas para
   esconderse hasta la próxima vuelta y pasarse a un carrito. El lavarropas que tiembla y dice "Ay, ay, ay" se abre
   con E y el preso sale mareado, caminando torcido.
9. **El final:** cuando el camión se va después de la cuarta vuelta, el caso termina. **Con 3 presos escapados se
   pierde.**
10. **El sueldo:** 600, 75 menos por cada preso escapado, 25 más por cada escondido atrapado antes de llegar al
    portón. Cuota propia de 400, como las otras cárceles.

## Lo que cambia con la semilla
Cuántos carritos llevan alguien (4 a 6) y cuáles, en qué vuelta sale cada uno, quién los empuja, en qué carritos sin
nadie duerme un gato, qué pistas da cada uno y cuándo un preso se mete en un lavarropas.

## Lo que se reusa
- La cárcel, el comedor, el patio y el portón (`PrisonLevel`); la cocina con su puerta, que se vuelve lavandería.
- Los presos del motín (modelo `npc_preso`), las esposas y llevarlos del brazo a la celda de castigo
  (`BlackoutEscort`).
- E y quedarse al lado (cachear del día de visitas) para revisar.
- Los objetos con física que se empujan y se vuelcan (las mesas del comedor).
- El gato de la peluquería para las pistas falsas.
- Lo nuevo: los carritos de ropa, los lavarropas y secarropas, el camión de la lavandería con su rampa, los presos
  que empujan y los escondidos.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. La lavandería: `--place=laundry`, la cocina con lavarropas, secarropas, mesa y soga, los 6 presos trabajando y los
   12 carritos con física.
3. Revisar: el camión que llega, los que empujan, E y quedarse 1,5 s, volcar, el escondido que salta y corre,
   esposarlo y llevarlo a la celda de castigo, y el que se sube al camión.
4. Las pistas: el estornudo, el pie, el peso, el silbido y el gato.
5. La vuelta de tuerca: el preso en el lavarropas.
6. El caso: el comisario, la planilla, el sueldo, la cuota, perder con 3 y el sorteo en Jugar (`PlaceDraw.PRISONS`,
   en quintos con el motín, el traslado, el corte de luz y el día de visitas).
7. Online: los carritos, los que empujan, los escondidos, el camión y el final.

## Preguntas para Cristian (respondidas: sí a las 3, 25/10)
1. **¿La lavandería va en la cocina del motín** (las ollas se cambian por lavarropas)? Recomendado: sí, la cocina ya
   tiene su puerta al comedor y el camino al portón ya existe; un cuarto nuevo cambia el mapa de todas las cárceles.
2. **¿Revisar un carrito sin nadie no resta, solo cuesta tiempo?** Recomendado: sí, el castigo es que el camión no
   espera: mientras revisas uno, los otros dos siguen caminando.
3. **¿Se pierde con 3 presos escapados?** Recomendado: sí, con 4 a 6 escondidos tiene que ser posible perder, y 3
   deja margen para un par de errores (igual que el día de visitas).

## Hecho así
- **Paso 2 (la lavandería):** `--place=laundry` abre `scenes/levels/prison_laundry.tscn`, la cárcel de día con
  `variant = "laundry"`. `LaundryPlan` saca la puerta de la cocina (para que pasen los carritos) y la vuelve lavandería:
  4 lavarropas y 2 secarropas contra la pared del este, la mesa de doblar con ropa doblada y una soga con 6 prendas
  colgadas. Hay 6 presos trabajando (`LaundryWorker`, el modelo del motín) en los lavarropas, el secarropas, la mesa y
  la soga, que se agachan sobre lo que hacen cuando el primer policía cruza el portón. Los 12 carritos
  (`LaundryCart`: canasto de lona, marco de metal, ruedas, manija y sábanas de colores arriba) esperan en dos filas
  junto a la pared del oeste. La semilla elige de 4 a 6 que llevan un preso abajo de la ropa y en cuál de los 4 viajes
  del camión sale cada uno (3 por viaje). Los carritos no se empujan a mano: los mueven los presos (paso 3). Capturas en
  `/mnt/project-files/lavanderia/`: `paso2-lavanderia.png` y `paso2-carritos.png`.
- **Paso 3 (el camión y revisar):** 20 s después de que entra el primer policía llega el camión de la lavandería
  (`LaundryTruck`, el camión de mudanza con el cartel "Lavandería Burbuja" y una rampa), y vuelve cada 2 minutos hasta
  hacer los 4 viajes. En cada viaje, 3 presos de la lavandería van a buscar los carritos de ese viaje (cada uno 6 s
  después del anterior): bajan por el pasillo de las máquinas, sacan el carrito al pasillo entre las dos filas y lo
  empujan delante ("Permiso, ropa sucia...") por la puerta de la cocina, el pasillo del comedor junto al mostrador, la
  puerta del este y el patio hasta el portón, donde sube por la rampa. Después vuelven a su lugar. El camión se va
  cuando suben sus 3 carritos, y después del cuarto viaje termina el día. E sobre un carrito y quedarse cerca (2,4 m)
  1,5 s lo revisa ("Puaj, está mojada"); R lo vuelca. Si había alguien, salta ("¡Sorpresa! ¡Chau, me voy!") y corre al
  portón por el mismo camino: se esposa y se lleva del brazo a la celda de castigo (lo del corte de luz, sin los ojos
  que brillan). Si llega al portón, o si el carrito sube al camión con él adentro, se escapó. Un carrito volcado
  mientras lo empujan se queda en el piso 4 s y el preso lo levanta ("¡Eh, mi ropa!"). Capturas:
  `paso3-empujando.png`, `paso3-camion.png` y `paso3-volcado.png`.
- **Paso 4 (las pistas):** el que está abajo de las sábanas estornuda cada 10 a 18 s ("¡Achís!") y las sábanas se
  mueven; en la mitad de esos carritos se le asoma un zapato por el borde, junto a la manija. El carrito con alguien
  adentro se empuja más lento (0,7 de la velocidad) y el que lo empuja resopla ("Uf... cómo pesa la ropa hoy...") y
  saluda nervioso a cualquier policía que se le acerca a 4 m ("¡Buenas, oficial! Nada raro por acá. Ropa. Solo ropa.",
  una vez cada 8 s). En uno de cada 3 carritos sin nadie duerme un gato en las toallas que maúlla cada 10 a 18 s y
  también mueve las sábanas; al revisarlo o volcarlo aparece el gato arriba de la ropa ("Solo un gato durmiendo en las
  toallas"). Las pistas salen de una semilla por carrito, igual en todas las PC. Capturas: `paso4-estornudo.png` y
  `paso4-gato.png`.
- **Paso 5 (el lavarropas):** los 4 lavarropas y los 2 secarropas son `LaundryMachine` y se abren con E (la puerta
  redonda se abre y se vuelve a cerrar). La semilla elige 2 de los 3 primeros viajes: a mitad de camino hasta el
  siguiente, un preso se mete en una máquina (también elegida por la semilla), que tiembla y cada 6 a 10 s se queja
  ("¡Ay, ay, ay! ¡Paren esto!"). Si nadie lo abre, cuando llega el próximo viaje se pasa a uno de sus carritos que no
  tenía a nadie ni estaba revisado (se le va el gato si había). Abierto antes, sale mareado ("Todo da vueltas...
  ¿Dónde está la puerta?"), se queda 5 s y después corre al portón como los de los carritos. Abrir una máquina vacía no
  resta ("Solo ropa dando vueltas"). Capturas: `paso5-lavarropas.png` y `paso5-mareado.png`.
- **Paso 6 (el caso):** el comisario lo cuenta en su oficina en tres partes (el camión de la Lavandería Burbuja,
  revisar con E y volcar con R y llevar al que salta a la celda de castigo, y los lavarropas) y Q abre la planilla
  (`LaundryCase`): viajes del camión, cuánto falta para el próximo (m:ss), presos encontrados en la ropa, presos
  escapados (con 3 se pierde) y el extra de los presos en la celda de castigo (cada uno cuenta una vez). Cuando el
  camión se va después del cuarto viaje se gana: sueldo de 600, 75 menos por cada escapado y 25 más por cada uno en la
  celda de castigo. Cuota propia de 400. En el sorteo de Jugar sale en un quinto de los casos de la cárcel
  (`PlaceDraw.PRISONS`, con el motín, el traslado, el corte de luz y el día de visitas). Captura: `paso6-planilla.png`.
- **Paso 7 (online):** decide el anfitrión. Los presos de la lavandería y los carritos van por `NpcSync` (dónde
  están, qué dicen, si trabajan; si el carrito está revisado, volcado o arriba del camión, el zapato y el gato); los que
  saltan los trae el anfitrión y a los invitados les llega la copia, con su camino a la celda de castigo para que la
  puedan llevar. E y R sobre los carritos y E sobre las máquinas van por `ActionSync`, pero solo el anfitrión sabe
  quién está abajo de la ropa o en un lavarropas. La planilla, el reloj del camión, el camión que llega y se va, las
  máquinas que tiemblan y el final van por `CaseSync` (`LaundryCase.snapshot`).
