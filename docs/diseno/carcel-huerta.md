# Cárcel 6.9: La huerta

Decisión 146 (propuesta). Caso de la cárcel ([carcel-motin.md](carcel-motin.md), fila 9 de la tabla). Todos los
números son (propuesta).

## La idea
La cárcel estrena su huerta en el patio: canteros de lechuga, zanahoria, tomate y zapallo que cuidan los presos con
regaderas. El director está orgulloso. Pero entre las verduras alguien plantó **porotos mágicos** que compró por
correo, y crecen rapidísimo: cuando una planta pasa el muro del patio, es una escalera para salir. El chiste: **hay que
encontrar la planta rara entre 48 verduras iguales antes de que crezca, y arrancarla aunque se resista**.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, la cárcel tiene huerta nueva. El director dice que son
   verduras. Yo vi un paquete que decía 'porotos mágicos, crecen hasta el cielo'. Vayan a mirar".
2. **La huerta:** 12 canteros en el patio (al lado de la cancha), cada uno con 4 plantas. 6 presos jardineros con
   regadera y sombrero de paja van de cantero en cantero regando y charlando. El horario de huerta dura 6 minutos.
3. **Las plantas raras:** la semilla elige 3 de las 48 plantas: son porotos mágicos. Empiezan iguales a las demás y
   crecen una etapa cada 40 s (brote, mata, planta, enredadera y gigante, 5 etapas), y la siguiente aparece 60 s
   después de la anterior. Las pistas: los jardineros riegan más las raras (y les cantan), las hojas se vuelven violetas
   desde la etapa 2, y de cerca hacen un ruidito ("crrc... crrc...").
4. **Arrancar:** E sobre una planta la arranca. Las de las etapas 1 y 2 salen con un policía; desde la etapa 3 se
   resisten y hacen falta 2 policías con E a la vez (uno solo si juega uno solo), tirando para atrás como en la
   cinchada. Arrancar una verdura normal por error: el jardinero más cerca se ofende ("¡Mi lechuga!") y resta 10.
5. **La fuga:** una planta gigante pasa el muro. Un preso trepa (10 s) y salta del otro lado: un escapado. Se lo
   puede bajar con E mientras trepa (cae sentado y se lo lleva del brazo a la celda de castigo), y la gigante se
   arranca igual con 2 policías. Mientras siga plantada, cada 30 s trepa otro.
6. **El final:** **se gana** cuando termina el horario de huerta con menos de 3 escapados; **se pierde con 3
   escapados**.
7. **El sueldo:** 600, 100 menos por cada escapado, 50 más por cada planta rara arrancada antes de la etapa 4, 25 más
   por cada preso bajado del muro y 10 menos por cada verdura arrancada por error. Cuota propia de 400, como las otras
   cárceles.

## Lo que cambia con la semilla
Qué 3 plantas son raras y en qué orden aparecen, qué verdura tiene cada cantero y a dónde va cada jardinero.

## Lo que se reusa
- La cárcel, su patio y su muro (`PrisonLevel`), los presos del patio (`YardInmate`, del túnel) para los jardineros.
- La celda de castigo, las esposas y llevarlo del brazo (`BlackoutEscort`).
- Varios policías con E a la vez (el aplauso del preso VIP) y el globito de texto.
- Lo nuevo: los canteros y las 4 verduras, la regadera, los porotos mágicos con sus 5 etapas, la cinchada y el que
  trepa.

## Atajos del panel de pruebas (cuando exista)
- Abrir la huerta (`--place=prison_garden`).
- Hacer crecer ya la próxima planta rara.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. La huerta: los canteros, las verduras y los jardineros regando (`--place=prison_garden`).
3. Los porotos mágicos: las 3 plantas raras, sus 5 etapas y sus pistas.
4. Arrancar: E, la cinchada de 2 policías y las verduras arrancadas por error.
5. La fuga: trepar la gigante, bajarlo del muro y la celda de castigo.
6. El caso: el comisario, la planilla, el sueldo, la cuota y el sorteo en Jugar (`PlaceDraw.PRISONS`, en novenos).
7. Online: las plantas, los jardineros, la cinchada y los que trepan.

## Preguntas para Cristian
1. **¿Lo raro son porotos mágicos que crecen hasta pasar el muro y sirven de escalera?** Recomendado: sí, se ve desde
   lejos cuando ya es tarde y obliga a mirar de cerca antes.
2. **¿Arrancar una verdura normal por error cuesta 10 y ofende al jardinero?** Recomendado: sí, así no conviene
   arrancar todo a lo loco.
3. **¿Las grandes (desde la etapa 3) necesitan 2 policías tirando a la vez (uno solo si juega uno solo)?**
   Recomendado: sí, es cooperativo y gracioso, y premia encontrarlas temprano.

## Hecho así
- **Paso 2:** `--place=prison_garden` (`scenes/levels/prison_garden.tscn`, `PrisonLevel.variant = "garden"`). En el
  este del patio, 12 canteros de 1,8 m (3 columnas x 4 filas, lejos del portón y de la cancha) con 4 plantas cada uno
  (`GardenPlant`: lechuga, zanahoria, tomate o zapallo; la semilla reparte 3 canteros de cada una). `GardenPlan`
  arranca el horario de huerta cuando el primer policía entra por el portón: los 6 jardineros (`YardInmate` en
  GARDEN, con sombrero de paja y regadera verde) van cada uno por 4 canteros de la semilla, se agachan un rato en cada
  uno y saludan al policía que pasa cerca. Capturas en `carcel-huerta/`: `paso2-huerta.png` y `paso2-cantero.png`.
- **Paso 3:** la semilla elige 3 plantas, cada una en un cantero distinto, que son porotos mágicos (`GardenPlant.magic`).
  El primero empieza a crecer a los 10 s del horario de huerta y cada uno de los otros 60 s después del anterior. Crecen
  una etapa cada 40 s: el tallo sale de la verdura (0,3 m, 0,75 m, 1,6 m, 3 m), con hojas violetas desde la etapa 2;
  el gigante se apoya sobre el muro más cercano, por arriba (`top`). A menos de 5 m un policía oye "crrc... crrc...".
  Cada cantero con poroto está en la ronda de 2 jardineros, que le cantan cuando lo riegan. Capturas:
  `paso3-brote.png` y `paso3-gigante.png`.
- **Paso 4:** E sobre cualquier planta dice "E: arrancar" (el cartel no delata cuál es rara). Un poroto hasta la etapa
  2 sale con un policía; desde la 3 se sacude y sale cuando 2 policías tiran con E en menos de 2 s (uno solo si juega
  uno solo). Arrancado, vuela del cantero y deja de crecer; cuenta como temprano si fue antes de la etapa 4. Una
  verdura arrancada por error también sale, y el jardinero más cerca grita ("¡Mi lechuga!"); el -10 se cobra en el
  paso 6. Capturas: `paso4-cinchada.png` y `paso4-arrancado.png`.
- **Paso 5:** mientras un poroto gigante siga plantado, cada 30 s (el primero enseguida, uno a la vez) el jardinero
  más cerca deja la regadera y va a su pie (`GardenClimber`, un `BlackoutInmate`): trepa 10 s hasta arriba del muro y
  salta afuera (escapado). E mientras trepa lo baja: cae sentado al pie, esposado, y se lo lleva del brazo a una celda
  (la de castigo, porque el pabellón está cerrado). Sin jardineros, el que trepa sale del comedor. Captura:
  `paso5-trepa.png`.
