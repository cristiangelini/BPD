# Cárcel 6.10: El recuento

Decisión 147 (propuesta). Caso de la cárcel ([carcel-motin.md](carcel-motin.md), fila 10 de la tabla). Todos los
números son (propuesta).

## La idea
Es la hora del recuento: el director tiene que contar 20 presos y cada vez le da un número distinto. Los presos no se
quedan quietos, se cambian de lugar, se borran la marca y tres ni siquiera están en el patio: se escondieron en la
cárcel y esperan el momento de salir. El chiste: **contar gente que se mueve es imposible, así que se los marca con
tiza uno por uno, y la lista dice a quién falta encontrar**.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, el director de la cárcel contó 20 presos, después 17, después
   23. O cuenta mal o le faltan presos. Vayan, cuéntenlos ustedes y que no se escape nadie".
2. **El patio:** los presos deambulan entre el patio y el comedor, charlan, se sientan y se levantan. En el patio
   hay un pizarrón grande, **la lista**, con las 20 fotos de los presos y el contador "contados 0 / 20".
3. **Marcar:** cada policía tiene una tiza. E sobre un preso le pinta una cruz amarilla en la espalda y su foto de la
   lista se tacha. Marcar a uno que ya tiene cruz no suma nada.
4. **Los tramposos:** 2 presos (los elige la semilla) cada 40 s se frotan la espalda contra la pared y se borran la
   cruz: su foto se destacha y hay que volver a marcarlos. Se los ve frotándose con un globito ("¡pica!").
5. **Los que no se ven:** en la cárcel también andan trabajadores con ropa parecida, el cocinero y el plomero. Marcar
   a uno por error resta 10 ("¡Yo trabajo acá!") y no suma en la lista.
6. **Los escondidos:** 3 presos de la lista no están en el patio. Cada uno está en uno de los escondites de la
   cárcel (8 en total, la semilla elige 3): un muñeco de almohadas en su cama (el de verdad está debajo), el tacho de
   basura del comedor, un carrito de la lavandería, debajo de la mesa larga, adentro del lavarropas, detrás de la
   máquina de gaseosas, en el techo del comedor y en la torre de agua. Las pistas: la lista dice qué fotos faltan, y
   de cerca el escondite ronca o se mueve. E sobre el escondite lo saca: queda esposado y se lo lleva del brazo al
   patio (con la cruz ya puesta).
7. **La fuga:** cada escondido sale a correr hacia el portón a su hora (el primero a los 90 s, después cada 60 s).
   Esposarlo antes de que llegue lo devuelve al patio; si llega, es un escapado.
8. **El final:** **se gana** cuando la lista marca 20 de 20 a la vez. **Se pierde** con 2 escapados o si se acaban
   los 6 minutos del recuento.
9. **El sueldo:** 600, 100 menos por cada escapado, 25 más por cada escondido encontrado antes de que salga a correr
   y 10 menos por cada trabajador marcado. Cuota propia de 400, como las otras cárceles.

## Lo que cambia con la semilla
Cuáles son los 2 tramposos, qué 3 presos se esconden y en cuáles de los 8 escondites, y por dónde camina cada uno.

## Lo que se reusa
- La cárcel con su patio, comedor, celdas y portón (`PrisonLevel`); los presos que deambulan (`YardInmate`).
- Revisar quedándose cerca, como los escondites de celda del túnel (`CellHideout`); los carritos de la lavandería
  (`LaundryCart`) como uno de los escondites.
- Los que corren al portón, las esposas y llevarlo del brazo (`BlackoutInmate`, `BlackoutEscort`).
- El trabajador ofendido (el jardinero de la huerta) y el globito de texto.
- Lo nuevo: la tiza y la cruz en la espalda, la lista con las fotos, los tramposos que se borran, el cocinero y el
  plomero.

## Atajos del panel de pruebas (cuando exista)
- Abrir el recuento (`--place=prison_count`).
- Mostrar dónde está cada escondido.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. El patio: los 17 presos que deambulan, el cocinero, el plomero y la lista con las fotos (`--place=prison_count`).
3. Marcar: la tiza, la cruz, el contador y los trabajadores marcados por error.
4. Los tramposos que se borran la cruz.
5. Los escondidos: los 8 escondites, sacarlos, la fuga al portón y esposarlos.
6. El caso: el comisario, la planilla, el sueldo, la cuota y el sorteo en Jugar (`PlaceDraw.PRISONS`, en décimos).
7. Online: las cruces, la lista, los escondidos y los que corren.

## Preguntas para Cristian
1. **¿Se cuenta marcando a cada preso con tiza (E) y una lista con sus 20 fotos en el patio?** Recomendado: sí,
   contar a ojo gente que se mueve es imposible y la lista dice a quién falta buscar.
2. **¿Los 3 que faltan están escondidos en la cárcel y salen a correr al portón si no se los encuentra a tiempo?**
   Recomendado: sí, así el caso es contar y además buscar, con apuro.
3. **¿Marcar por error al cocinero o al plomero cuesta 10?** Recomendado: sí, así no conviene marcar a todo el que
   pasa sin mirar.

## Hecho así
- **Paso 2:** `--place=prison_count` (`scenes/levels/prison_count.tscn`, `PrisonLevel.variant = "count"`). La lista
  (`CountBoard`) está en un pizarrón sobre dos patas contra el frente del edificio, al oeste de las puertas: como los
  presos usan el mismo modelo, en vez de fotos lleva **el número de cada uno** (01 a 20), y cada preso lo tiene pintado
  en el pecho y en la espalda. `CountPlan` saca al patio a los 17 que no se escondieron (`YardInmate`: 9 deambulan,
  4 dan vueltas a la ronda, 2 juegan al aro y 2 toman sol contra el muro este) y al cocinero y al plomero (modelos
  `npc_cocinero_carcel` y `npc_plomero`, naranjas como el mameluco y sin número), y todos se mueven cuando el primer policía
  entra por el portón. Por ahora se quedan en el patio, no entran al comedor. Capturas en `carcel-recuento/`:
  `paso2-patio.png`, `paso2-lista.png`, `paso2-numero.png`, `npc_cocinero.png` y `npc_plomero.png`.
- **Paso 3:** E sobre un preso del patio (`CountInmate`, que hereda de `YardInmate`) le pinta una cruz amarilla en la
  espalda (sin sombra, se ve igual a la sombra) y tacha su número en la lista con una X roja; dice "Presente." o
  algo así. No hay una tiza para agarrar: E alcanza. Marcar al cocinero o al plomero suma un error (`wrong`): se
  ofende ("¡Yo trabajo acá!"), sale el aviso "Ese no es un preso, no tiene número" y a los 3 s se limpia la cruz, así
  que se lo puede volver a marcar por error. `CountPlan.all_counted()` da verdadero con los 20 tachados a la vez.
  Capturas: `paso3-lista.png`, `paso3-cruz.png` y `paso3-cocinero.png`.
- **Paso 4:** la semilla elige 2 de los que deambulan como tramposos (`CountInmate.cheater`). Recién cuando tienen la
  cruz corre su reloj (40 s el primero, 60 s el segundo la primera vez, para que no vayan juntos): caminan a la pared
  más cerca (el muro oeste, el este o el frente del edificio), se ponen de espaldas, se refriegan 2,5 s ("¡Ay, cómo
  pica esta tiza!") y la cruz desaparece: su número vuelve a la lista (`CountPlan.rubbed`) y siguen deambulando.
  Capturas: `paso4-pica.png` y `paso4-lista.png` (la lista otra vez en 0 de 20).
- **Paso 5:** los 8 escondites (`CountHideout`) son los que se pueden armar sin abrir el pabellón (las camas quedan
  detrás de las rejas): en el comedor, el tacho de basura, el carrito de ropa sucia, la máquina de gaseosas y la pila
  de cajas de puré; en el patio, el contenedor, el cajón de pelotas junto al aro, la cucha del perro y el colchón
  contra el muro del fondo. Uno con alguien adentro ronca ("Zzz... ronc...") y se sacude cada 4 s si hay un policía a
  4 m. E revisa: vacío dice "Acá no hay nadie"; con alguien, sale con la cruz puesta, contado, y se queda deambulando
  por el patio (no hace falta llevarlo). Los que no se encontraron salen corriendo al portón en orden (a los 90 s,
  150 s y 210 s del recuento; desde el comedor, por su puerta más cerca), con su número en el mameluco: esposado y
  llevado a una celda queda contado; si llega al portón, la lista le pone "FUGA" y cuenta como resuelto, así que la
  lista se completa (20 de 20 entre contados y fugados) aunque alguno se haya escapado. Capturas:
  `paso5-comedor.png`, `paso5-patio.png`, `paso5-ronca.png` y `paso5-corre.png`.
- **Paso 6:** `CountCase`: el comisario lo cuenta en su oficina (3 líneas) y Q abre la planilla con el tiempo que
  queda, la lista tachada (contados más fugados, de 20), los escondidos encontrados (extra), los escapados (de 2) y los
  trabajadores marcados por error. Se gana apenas la lista se completa (`CountPlan.completed`); se pierde con 2
  escapados o a los 6 minutos (`CountPlan.ended`). Sueldo 600 - 100 por escapado + 25 por escondido encontrado - 10
  por trabajador marcado, cuota 400. Jugar sortea `prison_count` con las otras cárceles, ahora en décimos. Captura:
  `paso6-planilla.png`.
- **Paso 7:** online decide el `CountPlan` del anfitrión (`follower` en los invitados, también en los escondites). Los
  presos, el cocinero y el plomero los mueve `NpcSync`, con la cruz y si se están refregando en su estado; el que sale
  de un escondite y los que corren se copian con su número. La lista, quién está en cada escondite, el reloj y las
  cuentas llegan con el caso (`CountCase.snapshot`). Con 19 personas moviéndose en el patio los paquetes de `NpcSync`
  pasaban el MTU, así que ahora van de a 8 estados en vez de 12.
