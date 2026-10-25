# La fuga: disfrazados de limpieza (propuesta, 25/10)

Segunda variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.2: "pasando por delante del
comisario"). Usa todo lo que ya tiene la fuga de la dona ([fuga.md](fuga.md), decisión 99): las celdas con candado,
una sola fuga por partida, salir en el patrullero, "¡Fugados!" y perder a la tercera captura. Lo que cambia es cómo se
sale de la celda y quién vigila. Los números son **(propuesta)** hasta probarlos jugando.

## La idea
Es de madrugada (5:30). El guardia de noche ya se fue y llegó Clotilde, la de la limpieza, con su carrito. Abre cada
celda para trapear ("Permiso, permiso, levanten los pies.") y la deja abierta mientras limpia. El problema: el
comisario llegó temprano porque hoy tiene inspección, y anda dando vueltas entre su oficina, la cafetera de la sala de
guardia y la puerta de la sala de las celdas. Para pasar por delante de él, los cuatro se disfrazan con la ropa del
cuarto de limpieza y salen trapeando hasta el patrullero.

El chiste cooperativo: el comisario no mira caras, mira si se está limpiando. Mientras uno trapea delante de él para
que no gire, los otros cruzan detrás.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una, con las rejas cerradas (como la dona). Aviso: "Huele a
   lavandina. Llegó la limpieza... y el comisario, que madrugó."
2. **Clotilde hace su ronda:** entra a la sala de las celdas con el carrito, abre una celda, trapea adentro 20 s y la
   cierra con llave; después la otra. Repite cada 90 s. Mientras trapea, la reja queda abierta y los dos de adentro
   pueden salir. A Clotilde no le importa ("Yo limpio, no vigilo."), pero si pisan lo que acaba de trapear se queja
   ("¡Mi piso!").
3. **Las llaves en el carrito:** Clotilde deja su llavero colgado del carrito, en el pasillo. Los que salieron primero
   lo agarran con la mano y abren la otra celda (la llave de la fuga, `CellKey`, sirve para las dos).
4. **El cuarto de limpieza:** al lado de la sala de las celdas, con la puerta que se abre con las manos. Adentro hay
   por policía una gorra, un barbijo y un chaleco con la palabra "LIMPIEZA", y en la pared las herramientas: dos
   trapeadores, un plumero y una lustradora. El disfraz se pone como en la infiltración (`DisguisePiece`, llevándolo
   a la cabeza o al pecho): con 2 de las 3 piezas el policía pasa por "personal de limpieza".
5. **La lustradora:** pesada, se agarra con las dos manos y, prendida (E), gira y tira para cualquier lado. Limpia
   mucho de una pasada, pero el que la lleva va donde ella quiere, y si se suelta sale girando sola.
6. **Limpiar:** en el piso del pasillo, la sala de guardia y la entrada hay manchas (café, barro, huellas de zapatón,
   migas de dona; la semilla elige 8 a 12 de unos 20 lugares). Pasar la punta del trapeador o la lustradora sobre una
   mancha la borra en 2 s, y el piso queda mojado 20 s con un cartelito amarillo: el que corre por un piso mojado
   resbala y cae 2 s (como las canicas de los abuelos, `BankMarbles`).
7. **El comisario madrugador:** camina su ronda (oficina → cafetera → puerta de las celdas → oficina) con su taza, y
   mira con la misma mirada del guardia de noche (`NightGuard.sees`: cono de 70° y 10 m, no ve a través de paredes).
   Su sospecha (barra arriba, de 0 a 100) sube por segundo con lo que ve:
   - 50 por un policía sin disfraz fuera de las celdas.
   - 15 por un disfrazado que no limpia (quieto, sin herramienta o con la herramienta en el aire).
   - 25 por un disfrazado que corre.
   - 0 por un disfrazado que limpia.
   - Si borran una mancha delante de él, baja 20: "¡Qué brillo! Así me gusta." Sin nada raro a la vista baja 8.
8. **"¿Te conozco?":** si un disfrazado pasa a menos de 2,5 m de él, se frena, entrecierra los ojos y lo mira 3 s:
   "Mmm... ¿Te conozco de algún lado?". Si en esos 3 s el policía sigue limpiando, el comisario se convence ("No, no.
   Todos los de limpieza se parecen.") y sigue. Si no limpia, la sospecha sube 40 de golpe.
9. **La captura:** a 100 los reconoce: "¡Novatos! ¿Qué hacen vestidos así? ¡A la celda!". Como con el guardia, los
   que estaban afuera vuelven a una celda con las manos vacías, se les cae el disfraz (vuelve al cuarto), el llavero
   vuelve al carrito y las rejas se cierran. Las capturas cuentan igual: "Capturas del comisario: 1 de 3".
10. **Salir:** por la sala de guardia y la puerta de la calle hasta el patrullero, como en la dona. Ojo: si el
    comisario ve a alguien de limpieza subir al patrullero, la sospecha va directo a 100 ("¿Desde cuándo la limpieza
    maneja patrulleros?"). Hay que subir cuando él está en la oficina o mirando para otro lado. Con todos en el auto a
    25 m del estacionamiento: "¡Fugados!".
11. **Perder:** a la tercera captura el comisario no llama a nadie, ya está ahí: "¡Tres veces! ¡Suspendidos, todos!
    Y devuelvan esos chalecos.". Termina la partida con "Suspendidos", igual que la dona.

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- Qué celda abre primero Clotilde.
- Dónde están las manchas (8 a 12 de unos 20 lugares) y de qué son.
- Por dónde arranca la ronda del comisario y cuánto se queda en cada parada (4 a 8 s).
- Qué cosa de limpieza falta en el cuarto (siempre hay al menos 2 piezas por policía y 2 herramientas).
- Las frases: 10 o más de Clotilde, del comisario mirando y del "¿Te conozco?", con `tr()` en es, en y pt.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento. Sigue el turno siguiente sin la plata
  del turno fallado (decisión 99).
- **Se pierde** a la tercera vez que el comisario los reconoce: "Suspendidos".
- **Sin tiempo límite** (decisión 66): la presión es la ronda del comisario y las rejas que Clotilde vuelve a cerrar.

## Lo que se reusa
`JailbreakLevel` (celdas, candados, capturas, salida, final y guardado en `Campaign`), `CellKey`, `CellDoor`,
`DisguisePiece` (con un look nuevo "cleaner" y la pieza al pecho, como la túnica del coro), la mirada de `NightGuard`,
el resbalón de `BankMarbles`, el modelo del comisario y `Grabbable` para las herramientas. Nuevo: Clotilde y su
carrito, el cuarto de limpieza, las manchas, el trapeador, el plumero, la lustradora y la ronda del comisario.

## Online
Todo lo decide el anfitrión, como el resto de la fuga: la semilla, la ronda de Clotilde y del comisario, las manchas,
la sospecha y las capturas. Clotilde y el comisario van por `NpcSync`; el llavero, las herramientas y los disfraces por
`PropSync`; las manchas borradas y el piso mojado en el estado del caso.

## Atajos del panel de pruebas
- Empezar la fuga de limpieza (`--jailbreak=cleaning`).
- Abrir la celda de Clotilde ya.
- Mostrar la ronda del comisario.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo de la variante en la fuga (`JailbreakLevel.variant`: dona o limpieza, `--jailbreak=`), la madrugada sin
   guardia y Clotilde con su carrito haciendo la ronda y abriendo las celdas (modelos nuevos en `tools/modelgen`).
2. El llavero en el carrito y el cuarto de limpieza con los disfraces (look "cleaner") y las herramientas.
3. Las manchas, limpiar con el trapeador y la lustradora, y el piso mojado que resbala.
4. El comisario madrugador: su ronda, la mirada, la sospecha por disfraz y limpieza, "¿Te conozco?" y la captura.
5. Salir (subir al patrullero a la vista), perder a la tercera, frases y online.

## Preguntas para Cristian (respondidas el 25/10: sí a las tres, decisión 150)
1. ¿La fuga sortea entre la dona y la limpieza mitad y mitad con la semilla? **Recomiendo sí:** las dos ya comparten
   celdas, salida y final, y así cada partida puede tener una fuga distinta.
2. ¿Que el comisario no mire caras sino si limpian, con el "¿Te conozco?" de cerca? **Recomiendo sí:** es el chiste
   de pasar por delante de él y obliga a cubrirse entre los cuatro.
3. ¿Que no puedan subir al patrullero si él los ve? **Recomiendo sí:** sin eso, el final es correr hasta el auto
   disfrazados y listo.
