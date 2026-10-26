# La fuga: el simulacro de incendio (decisión 155, 25/10)

Séptima variante de la fuga (tipo 7 del catálogo, [casos.md](casos.md), punto 7.7: "salen entre la gente").
Usa todo lo de la fuga de la dona ([fuga.md](fuga.md), decisión 99) y de las otras cinco
([fuga-limpieza.md](fuga-limpieza.md), [fuga-perro.md](fuga-perro.md), [fuga-tunel.md](fuga-tunel.md),
[fuga-ventilacion.md](fuga-ventilacion.md), [fuga-basura.md](fuga-basura.md), decisiones 150 a 154): celdas con
candado, una sola fuga por partida, salir en el patrullero, "¡Fugados!" y perder a la tercera captura. Los números son
**(propuesta)** hasta probarlos jugando.

La 7.6 del catálogo (sobornar al guardia) queda para después: necesita la plata de las coimas (decisión 30), que
todavía no existe.

## La idea
Es de día y la comisaría está llena: gente esperando para hacer denuncias, una señora con su gato, el repartidor de
pizza, un abuelo que vino a quejarse del ruido. El guardia de día vigila las celdas desde su escritorio con la llave en
el cinturón. En el techo de cada celda hay un detector de humo, y en la celda hay una estufa vieja.

El plan: hacer humo. Si suena la alarma, el reglamento dice que hay que evacuar a todos, presos incluidos, al punto de
encuentro en la vereda. Ahí afuera, entre veinte personas, los presos con su chaleco naranja tienen que dejar de parecer
presos y caminar tranquilos hasta el patrullero.

El chiste cooperativo: el guardia cuenta presos en el punto de encuentro, con su planilla, uno por uno. Mientras uno le
discute la cuenta ("Yo soy el tres, no el cuatro"), los otros se sacan el chaleco y se pierden entre la gente.

## Cómo es
1. **Despertar:** los 4 en las celdas, dos en cada una, con chaleco naranja de preso y las rejas cerradas. El guardia
   en su escritorio. En la sala de espera, 8 a 12 personas (la semilla elige cuáles y dónde). Aviso: "Esa estufa
   huele raro... ¿y si la ayudamos un poco?"
2. **El humo:** la frazada de la cucheta, sostenida contra la estufa (E, con la frazada en la mano), hace humo. Con 8 s
   de humo seguidos suena el detector de esa celda. Mientras humea, el guardia lo puede ver: si mira la celda, la
   sospecha sube 20 por segundo ("¿Qué están quemando ahí?"). Soltar la frazada corta el humo y hay que empezar de
   nuevo.
3. **La alarma:** suena en toda la comisaría y empieza el simulacro, 120 s. El guardia toca el silbato: "¡Simulacro!
   ¡Todos afuera, en fila, sin correr!". Abre las dos celdas y los presos tienen que salir en fila detrás de él.
4. **La evacuación:** la gente de la sala de espera sale caminando por la puerta del frente hacia el punto de
   encuentro (la vereda, frente al estacionamiento), cada uno a su manera: la señora con el gato en brazos, el abuelo
   despacio, el repartidor con la pizza. El guardia camina adelante de los presos hasta la puerta y después se para en
   el punto de encuentro con la planilla.
5. **Dejar de ser preso:** el chaleco naranja se saca con E (2 s) y se deja en cualquier lado. En la sala de espera hay
   un perchero con abrigos y sombreros: ponerse uno (como el disfraz de limpieza, `DisguisePiece`) hace pasar al
   policía por "público". Sin chaleco y sin abrigo, con el uniforme, también se nota: el guardia lo reconoce si lo ve.
6. **La cuenta:** en el punto de encuentro el guardia cuenta presos cada 20 s: cuenta los chalecos naranjas que ve.
   Si faltan, sospecha +25 y camina entre la gente mirando caras. A un policía disfrazado lo reconoce solo de cerca
   (a menos de 2 m durante 3 s: "¿A ti no te conozco?"): captura. Un chaleco tirado en el piso que ve también suma
   sospecha.
7. **Salir:** todos al patrullero, a 25 m del estacionamiento, mientras dura el simulacro: "¡Fugados!". Subir al
   patrullero con el chaleco puesto, a la vista del guardia, es captura.
8. **Fin del simulacro:** a los 120 s, "¡Bueno, todos adentro!": la gente vuelve a la sala de espera y los presos que
   quedan, a las celdas. Los chalecos se los vuelven a poner. El detector queda con un aviso ("Se cambió la pila") y
   la estufa ahora tiene un cartel "NO TOCAR": el próximo humo tarda el doble.
9. **La captura:** a 100 de sospecha o si lo reconoce: todos a las celdas con chaleco, y si era durante el simulacro,
   se termina. A la tercera llama al comisario: "Suspendidos".

## Lo que varía con la semilla (decisión 19: nada sale igual dos veces)
- Quién está en la sala de espera (de unas 12 personas posibles, 8 a 12) y dónde se para cada uno en la vereda.
- Qué abrigos hay en el perchero (sombrero de copa, piloto, tapado de piel, campera de moto...).
- Las frases: 10 o más del guardia contando, de la gente quejándose del simulacro y de los reconocimientos, con `tr()`.

## Cómo se gana y cómo se pierde
- **Se gana** como la dona: todos en el patrullero, a 25 m del estacionamiento.
- **Se pierde** a la tercera captura: "Suspendidos".
- **Sin tiempo límite** (decisión 66): si el simulacro termina sin todos afuera, se puede volver a hacer humo.

## Lo que se reusa
`JailbreakLevel` (celdas, capturas, salida, final, guardado y sorteo), `NightGuard` (la mirada y la sospecha, ahora de
día), el disfraz de la limpieza (`DisguisePiece`, `Cop.put_on_disguise`), la gente de la ciudad para la sala de espera
(modelos `npc_*`) y la caminata de los guardias de la basura y del túnel. Nuevo: la estufa y la frazada, el detector
y la alarma, el chaleco naranja, el perchero, la gente que evacúa y el guardia con la planilla.

## Online
Todo lo decide el anfitrión: el humo, la alarma, el simulacro, la gente, la cuenta, la sospecha y las capturas. El
guardia y la gente van por `NpcSync`; los chalecos y los abrigos, por `PropSync` y el disfraz de cada policía como en
la limpieza.

## Atajos del panel de pruebas (cuando exista)
- Empezar la fuga del simulacro (`--jailbreak=drill`).
- Que suene la alarma ya.

## El orden para hacerlo (un PR chico por paso)
1. El sorteo en séptimos (`--jailbreak=drill`), el guardia de día, la sala de espera con gente, el chaleco naranja,
   la estufa, la frazada, el humo y el detector (modelos en `tools/modelgen`).
2. La alarma y el simulacro: abrir celdas, la gente y los presos evacuando, el punto de encuentro, la vuelta a los
   120 s.
3. El chaleco que se saca, el perchero y los abrigos, la cuenta y el reconocimiento, salir, frases y online.

## Preguntas para Cristian (respondidas el 25/10: sí a las tres, decisión 155)
1. ¿La fuga sortea en séptimos entre las siete variantes? **Recomiendo sí:** todas comparten celdas, salida y final.
2. ¿La alarma se dispara haciendo humo con la frazada en la estufa de la celda (y no con un botón de alarma afuera)?
   **Recomiendo sí:** se hace desde adentro de la celda, el guardia lo puede ver y es lo bastante absurdo.
3. ¿El simulacro es de día con la sala de espera llena de gente? **Recomiendo sí:** "salir entre la gente" necesita
   gente, y de noche la comisaría está vacía.
