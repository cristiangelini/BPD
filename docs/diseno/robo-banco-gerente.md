# BPD · Robo a un banco: El ladrón es el gerente (propuesta, 25/10)

Quinta variante del robo a un banco en vivo ([casos.md](casos.md), 10.10), sobre la base de los ladrones con máscaras
de animales ([robo-banco.md](robo-banco.md), decisión 102), junto a la fiesta de los rehenes
([robo-banco-rehenes.md](robo-banco-rehenes.md), decisión 121), los ladrones abuelos
([robo-banco-abuelos.md](robo-banco-abuelos.md), decisión 122) y el ladrón arrepentido
([robo-banco-arrepentido.md](robo-banco-arrepentido.md), decisión 123). Todos los números son **(propuesta)** hasta
probarlos jugando. La decisión de esta variante es la 124, de las que quedan del hilo A.

## La idea
El robo base ya decía que la llave de la puerta de atrás está en el auto del gerente, que espera afuera en pijama
(robo-banco.md, punto 5), pero eso nunca se hizo: hoy la puerta de atrás no abre sin el arrepentido. Esta variante lo
hace en dos partes. Primero, **en todos los robos al banco** aparece el señor Moneda, el gerente, en pijama y pantuflas
al lado de su auto en la vereda: se queja, tiene frío y le da la llave de atrás al policía que le habla. Después, en
la variante "el ladrón es el gerente", el señor Moneda es el verdadero jefe de la banda: El Oso solo le hace caso, la
llave que te da no abre nada y su auto espera con el baúl abierto para llevarse la plata. El chiste cooperativo:
darse cuenta de que el que tirita en la vereda es el jefe, antes de que se vaya con la plata, sin esposar a un gerente
inocente en los otros robos.

## La historia del comisario
"¡Novatos! ¡Roban el Banco del Barrio! El gerente los espera en la puerta, pobre hombre, en pijama... Atiéndanlo
bien."

## Cómo es el caso
1. **El gerente en todos los robos:** el señor Moneda espera al lado de su auto, en la vereda frente al banco. Camina
   un poco, se frota los brazos y dice cosas en un globito ("¡Mi banco!", "¡Hace frío!"). Con E te da la llave de la
   puerta de atrás: "Tome, la de atrás. Cuídela". Con esa llave el policía abre la puerta de atrás desde afuera (hoy
   está trabada). Esposarlo cuando es inocente cuesta 200 del sueldo y queda libre enseguida: "¡Soy la víctima!" (ver
   pregunta 1).
2. **Cuando es el jefe:** se comporta igual a primera vista, pero tiene tres pistas para el que mira (ver pregunta 2):
   - **La llave equivocada:** la que te da no abre la puerta de atrás ("No entra..."). La llave de verdad la tiene él
     en el bolsillo del pijama.
   - **El walkie en el bolsillo:** cada 20 a 30 s se da vuelta, saca un walkie del pijama y murmura "Apúrense"; si
     no hay un policía a menos de 6 m, el taladro va más rápido 10 s. Mientras habla, la antena se ve 2 s (el tic, como
     el control del auto fantasma).
   - **El baúl abierto:** su auto tiene el baúl abierto con bolsas vacías adentro. Si un policía lo cierra, el gerente
     lo vuelve a abrir "para que se airee".
   Además El Oso, por teléfono, a veces se equivoca: "Tengo que consultarlo con el je... con mis amigos".
3. **Esposarlo cuando es el jefe:** el gerente esposado cuenta como el jefe. La banda se entera por el walkie, se
   pone nerviosa una vez y El Oso cuelga el teléfono: "¿Jefe? ¿Jefe?". Desde ahí no hay más pedidos por teléfono.
4. **La huida:** cuando la bóveda se abre, los ladrones sueltos salen por atrás con las bolsas, las tiran en el baúl
   del gerente y el gerente se va en su auto (los ladrones se van en la camioneta, como siempre). Arranca la
   persecución con el auto del gerente: si se lo para, se lo esposa. Si el gerente ya estaba esposado, las bolsas
   quedan en la vereda y la huida es la de siempre, con El Oso.
5. **Se gana** con el gerente esposado (adentro de la persecución o antes); El Oso esposado suma, pero solo no
   alcanza. Sueldo de 700, 100 menos por cada rehén que quede adentro y 50 menos por cada bolsa que se lleven; +100 si
   esposan al gerente antes de que se abra la bóveda. Cuota propia de 400. **Se pierde** si el gerente se escapa en su
   auto (ver pregunta 3).

## Lo que se reusa
Todo el banco del robo base (lote, hall, bóveda, puerta de atrás, ventilación), la banda con sus conos, el taladro con
`hurry`, el teléfono de El Oso, las esposas y la escolta (OwnerEscort), la persecución embebida (ChaseCase.begin) y el
tic del auto fantasma. Lo nuevo: el gerente en pijama con su auto, la llave de atrás (que también sirve en las otras
variantes), el walkie, el baúl y la huida en su auto.

## El orden para hacerlo (un PR chico por paso)
1. El gerente en pijama al lado de su auto en todos los robos, con E te da la llave y la llave abre la puerta de atrás.
   El sorteo pasa a quintos (fiesta, abuelos, arrepentido, gerente y base).
2. El gerente jefe: la llave equivocada, el walkie con su tic que acelera el taladro y el baúl abierto con bolsas.
3. Esposarlo: culpable (El Oso cuelga, la banda nerviosa) o inocente (200 menos y queda libre).
4. La huida en su auto con las bolsas y la persecución, y el caso (radio del comisario, planilla, sueldo y cuota).
5. El online.

## Preguntas para Cristian
1. **¿El gerente en pijama aparece en todos los robos al banco, y esposarlo cuando es inocente cuesta 200?**
   Recomendado: sí, así hay que darse cuenta de verdad y la llave de atrás por fin existe. La otra opción es que solo
   aparezca en esta variante (más fácil, pero se adivina apenas lo ves).
2. **¿Las pistas son la llave que no abre, el walkie en el bolsillo y el baúl abierto con bolsas vacías?**
   Recomendado: sí, las tres a la vez. La otra opción es una sola pista al azar por partida (más difícil).
3. **¿Se gana con el gerente esposado, y El Oso solo no alcanza?** Recomendado: sí, el gerente es el jefe y si se
   escapa en su auto se pierde. La otra opción es que gane cualquiera de los dos y el gerente solo sume 100.

## Hecho así

- **Paso 1 (el gerente y la llave):** en todos los robos al banco el señor Moneda (`BankManager`, modelo `npc_gerente`
  en pijama verde a rayas) camina de ida y vuelta por la vereda al lado de su auto (`manager_car`, un sedán bordó
  estacionado al oeste de la entrada), tirita cuando se para y se queja cada 9 s (`MANAGER_1-4`). E sobre él le da al
  policía la llave de la puerta de atrás (`Cop.has_key`, la misma de las macetas del abuelo) y después solo se queja
  (`MANAGER_AGAIN_1-3`); con la llave la puerta de atrás abre desde afuera. El sorteo pasa a quintos: primero el
  gerente jefe (`hash(["bank moneda", semilla]) % 5`), y el resto sigue en cuartos como antes, así las semillas de las
  pruebas viejas no cambian. `--bank=manager` lo fuerza. El walkie del modelo queda escondido hasta el paso 2.
  Capturas en `/mnt/project-files/gerente/paso1-*.png`.
- **Paso 2 (las pistas del jefe):** en la variante del gerente jefe la llave que da no abre la puerta de atrás
  (`FrontDoor.wrong_key`: "La llave no entra... Esta no es."). Cada 20 a 30 s se para, saca el walkie del bolsillo del
  pijama 2 s y murmura al walkie (`MANAGER_WALKIE_1-3`, `BankManager.radio`); si no hay ningún policía a 6 m de él, el
  taladro va más rápido 10 s (`BankDrill.hurry`). Su auto tiene el baúl abierto con dos bolsas vacías
  (`ManagerTrunk`): E lo cierra y a los 6 s él lo vuelve a abrir, "¡Déjelo abierto, que se airee!". Una de cada tres
  quejas lo delata (`MANAGER_BOSS_1-2`). El gerente honesto no tiene walkie ni baúl abierto. El desliz de El Oso por
  teléfono queda para el paso 4. Capturas en `/mnt/project-files/gerente/paso2-*.png`.
