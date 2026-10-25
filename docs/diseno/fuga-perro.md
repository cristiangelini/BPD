# La fuga: el perro guardián (propuesta, 25/10)

Tercera variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.8: "hay que hacerse amigo con
comida"). Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y lo que sumó la de limpieza
([fuga-limpieza.md](fuga-limpieza.md), decisión 150): celdas con candado, una sola fuga por partida, salir en el
patrullero, "¡Fugados!" y perder a la tercera captura. Los números son **(propuesta)** hasta probarlos jugando.

## La idea
Es de noche. El guardia de noche se quedó dormido en su escritorio, roncando, y la llave de las celdas no la tiene él:
cuelga del collar de Mordisco, el perro guardián de la comisaría, un bulldog enorme y babeador que da vueltas por la
sala de guardia. Mordisco no muerde, pero ladra a todo el que no conoce, y si ladra mucho despierta al guardia. Para
salir, los cuatro se tienen que hacer amigos de Mordisco con comida, uno por uno, hasta que se deje sacar la llave.

El chiste cooperativo: cada uno tiene que ganarse al perro. El que ya es amigo lo distrae y lo lleva de paseo mientras
el que no lo es cruza detrás, y la comida es poca y no toda le gusta.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una, con las rejas cerradas. El guardia ronca en el escritorio.
   Aviso: "Ronquidos... y un perro enorme con la llave en el collar."
2. **Mordisco:** camina entre 5 lugares de la sala de guardia y de la sala de las celdas (la semilla elige el orden y
   cuánto se queda en cada uno, de 4 a 10 s). Tiene la llave de las celdas (`CellKey`) colgada del collar.
3. **La comida:** en cada celda hay una bandeja de la cena con 2 cosas; en la sala de descanso, una heladera con 4
   más, y en el escritorio, el sándwich del guardia (al lado de su cara). La semilla elige qué hay:
   - Salchicha: amistad +40. Jamón: +30. Queso: +20. Dona: +10 (le encanta, pero con 3 se empacha y se acuesta 15 s).
   - Lechuga: -10, la escupe ("Grrr.").
   - El sándwich del guardia: +50, pero el que lo agarra con el guardia despierto suma sospecha como un policía afuera.
4. **Dar de comer:** la comida se tira o se deja en el piso. Mordisco huele lo que hay a menos de 8 m, va, se lo come
   (2 s) y la amistad sube con el que la tiró o la soltó. Si alguien tiene comida en la mano a menos de 3 m de él, se
   sienta y pide ("¿Me das?"), y no ladra.
5. **La amistad:** va de 0 a 100 y es de cada policía. Con 100 Mordisco lo conoce: mueve la cola, lo sigue si lo
   llama (tecla de silbar, la misma de cantar) y se deja acariciar (E). Acariciarlo con la llave en el collar se la
   saca: "Buen chico. Esto me lo llevo." La amistad baja 2 por minuto si no come nada.
6. **Ladrar:** si ve (cono de 120° y 8 m, la mirada de `NightGuard.sees`) a un policía fuera de las celdas que no es su
   amigo, le ladra. Cada segundo de ladrido acerca al guardia a despertarse; a los 3 s se despierta.
7. **El guardia:** dormido no ve nada. Despierto mira como el de la dona (cono de 70° y 10 m) y la sospecha sube igual
   (50 por segundo por un policía afuera). Si pasan 20 s sin ver nada raro, se vuelve a dormir: "Perro tonto... zzz."
   Un grito al micrófono cerca también lo despierta.
8. **La captura:** a 100 de sospecha el guardia se levanta: "¡Novatos! ¡Y tú, Mordisco, a cuidar!". Los de afuera
   vuelven a una celda, las rejas se cierran, la llave vuelve al collar y la comida que ya se comió no vuelve. La
   amistad no se pierde (el perro se acuerda). Las capturas cuentan igual: "Capturas del guardia: 1 de 3".
9. **Salir:** con la llave abren las celdas y van por la sala de guardia y la puerta de la calle al patrullero. Si
   Mordisco es amigo de los cuatro, se sube al patrullero con ellos ("¡Guau!"), y el final dice "¡Fugados! (con perro)".
   Si no, se queda ladrando en la puerta.
10. **Perder:** a la tercera captura el guardia llama al comisario, que llega en pijama, como en la dona:
    "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- La ronda de Mordisco: el orden de los lugares y cuánto se queda en cada uno.
- Qué comida hay en cada bandeja y en la heladera (siempre alcanza para 4 amigos si nadie la desperdicia: al menos
  400 de amistad en total, sin contar el sándwich).
- Las frases: 10 o más de los ladridos, del guardia dormido y despierto y del perro pidiendo, con `tr()` en es, en y pt.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento. Sigue el turno siguiente sin la plata
  del turno fallado (decisión 99).
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66): la presión es la comida que se acaba y el guardia que se despierta.

## Lo que se reusa
`JailbreakLevel` (celdas, candados, capturas, salida, final y guardado en `Campaign`, y `variant` con el sorteo),
`CellKey`, `CellDoor`, `NightGuard` (la mirada, la sospecha, dormirse y despertarse), `Grabbable` para la comida y el
tirar con `throw_toward`, la tecla de cantar para silbar. Nuevo: Mordisco (modelo y comportamiento), la comida, las
bandejas de la cena y la heladera.

## Online
Todo lo decide el anfitrión: la semilla, la ronda de Mordisco, qué come y con quién sube la amistad, los ladridos, el
guardia y las capturas. Mordisco y el guardia van por `NpcSync` (con la amistad de cada policía); la comida y la llave,
por `PropSync`.

## Atajos del panel de pruebas
- Empezar la fuga del perro (`--jailbreak=dog`).
- Mordisco amigo de todos ya.
- Despertar al guardia.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo con tres variantes (`--jailbreak=dog`), el guardia dormido en el escritorio que se despierta y se vuelve a
   dormir, y Mordisco (modelo en `tools/modelgen`) caminando su ronda con la llave en el collar.
2. La comida: bandejas, heladera y sándwich, Mordisco que la huele, va y se la come, y la amistad de cada policía.
3. Ladrar a los desconocidos, que despierta al guardia; pedir comida, seguir al amigo que silba y sacarle la llave
   acariciándolo.
4. Salir: Mordisco en el patrullero con los cuatro amigos, perder a la tercera, frases y online.

## Preguntas para Cristian
1. ¿La fuga sortea entre dona, limpieza y perro en tercios con la semilla? **Recomiendo sí:** las tres comparten
   celdas, salida y final.
2. ¿Que la amistad sea de cada policía (los cuatro tienen que darle de comer) y no una sola para todos? **Recomiendo
   sí:** obliga a repartir la comida y a cubrirse entre los que ya son amigos y los que no.
3. ¿Que los ladridos despierten al guardia (y no que el perro los atrape él mismo)? **Recomiendo sí:** así el perro
   nunca es malo, solo ruidoso, y el que atrapa sigue siendo el guardia.

## Cómo quedó el paso 1
- `JailbreakLevel.VARIANTS` suma "dog" (`--jailbreak=dog`): el sorteo queda en tercios.
- `SleepyGuard` (hereda de `NightGuard`): duerme en el escritorio sin donas hasta que 3 s de ladridos
  (`heard_bark`) o un grito lo despiertan; despierto vigila igual que el de la dona y a los 20 s sin ver nada raro se
  vuelve a dormir. Ronca cada 5 s.
- `GuardDog` (Mordisco, modelo `guard_dog` en `tools/modelgen/models/guarddog.js`): camina ida y vuelta entre la sala
  de guardia, la puerta de las celdas, el pasillo frente a las dos celdas y el costado del escritorio, y se queda de 4
  a 10 s en cada parada. La llave cuelga del collar (`key_on_collar`, la parte `key` del modelo). Va por `NpcSync`.
- Captura del modelo: `/mnt/project-files/perro/paso1-mordisco.png`.

## Cómo quedó el paso 2
- `DogFood` (salchicha, jamón, queso, dona, lechuga y el sándwich, modelos `dog_*` en `guarddog.js`): recuerda al
  último policía que la agarró, que es quien recibe la amistad.
- Para que siempre alcance, hay más comida que en la propuesta: 3 cosas en cada bandeja (al fondo de cada celda, lejos
  de las rejas: hay que tirarlas afuera), 9 en la heladera abierta de la sala de descanso (3 estantes) y el sándwich
  en el escritorio. `JailbreakLevel.dog_food_kinds` sortea por peso y cambia lo que menos le gusta por salchichas hasta
  sumar 400 de amistad.
- Mordisco huele la comida quieta en el piso a menos de 8 m, va y la come en 2 s. Si está en una celda solo la alcanza
  a menos de 0,9 m de las rejas. La lechuga la escupe (-10) y con 3 donas se tira panza arriba 15 s.
- La amistad baja 2 por minuto solo mientras no llega a 100: el amigo queda amigo.
- El sándwich por ahora no suma sospecha propia: el que lo agarra con el guardia despierto ya está a la vista.
- Captura: `/mnt/project-files/perro/paso2-comida.png`.
