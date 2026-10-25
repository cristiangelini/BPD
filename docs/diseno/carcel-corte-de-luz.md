# BPD · Cárcel: corte de luz (propuesta, 25/10)

Variante 7 de la cárcel ([carcel-motin.md](carcel-motin.md), tabla de variantes; [casos.md](casos.md), 6.7). Usa la
cárcel de la cuadra (5, 2) que ya hizo el motín. Decisiones 140 a 149. Todo es **(propuesta)** hasta que Cristian
responda las preguntas de abajo y se pruebe jugando.

## La idea
Se cortó la luz en la cárcel y, como las celdas tienen cerradura eléctrica, se abrieron todas. Los guardias se
quedaron en el patio con velas, muertos de miedo. Los 4 novatos entran a oscuras, solo con sus linternas, a meter a los
presos de vuelta en las celdas y a arreglar el tablero de la luz. El chiste: **los presos se quedan duros cuando los
alumbra una linterna** (como en "luz roja, luz verde") y se mueven en cuanto la linterna mira para otro lado. Uno
alumbra, otro esposa, otro busca los fusibles en la oscuridad.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, se cortó la luz en la cárcel y se abrieron las celdas. Lleven
   las linternas, encierren a todos y arreglen esa luz. Y no dejen que nadie llegue al portón".
2. **A oscuras:** al cruzar el portón, el edificio está negro. Las lámparas del techo apagadas, el sol tapado (es de
   noche en la cárcel, como en la fuga) y la única luz son las linternas de los policías (F, la que ya existe) y las
   velas de los guardias en el patio. En la oscuridad a los presos solo se les ven **los ojos**, dos puntitos blancos
   que parpadean.
3. **Los presos:** 12 con mameluco naranja (el modelo del motín) salen del pabellón. Cada uno, con la semilla, hace una
   de tres cosas: **se esconde** (debajo de una mesa del comedor, detrás del mostrador, en la cocina, en una celda que
   no es la suya), **pasea** sin rumbo, o **va al portón** a escaparse por el patio. Los guardias del patio no los
   paran: tiemblan con su vela.
4. **La linterna los congela:** un preso dentro del cono de una linterna prendida (18 m y 22°, sin paredes en el
   medio) se queda duro en la pose que tenía, con una frase ("¡Ay, la luz!", "Yo no me muevo, eh"). Un segundo después
   de que la luz se va, vuelve a moverse. Dos linternas sobre el mismo preso no cambian nada; cada linterna congela a
   todos los que alumbra.
5. **Esposarlo y llevarlo:** a un preso congelado se lo esposa (E, como en el motín) y se lo lleva del brazo
   (`PrisonEscort`) a cualquier celda del pabellón. Adentro, E sobre la reja la cierra a mano (sin luz, la cerradura no
   traba sola; cada reja aguanta cerrada hasta que vuelva la luz). Un preso esposado no se mueve aunque esté a oscuras.
   Una celda abierta con un preso adentro y sin esposas: el preso se vuelve a ir.
6. **Escaparse:** el preso que llega al portón se escapa ("¡Chau, novatos!"), se pierde en la noche y cuenta en la
   planilla. **Con 4 escapados se pierde el caso**, como en el traslado (decisión 105).
7. **El tablero de la luz:** en el pasillo del pabellón hay un tablero con 3 fusibles quemados. Los fusibles nuevos
   están en la oscuridad, cambiando de lugar con la semilla: uno en la cocina, uno en el comedor o el pabellón, y el
   tercero **lo tiene El Chispa**, el preso que cortó la luz (ver abajo). Con un fusible en la mano, E sobre el
   tablero lo pone. Con los 3, vuelve la luz.
8. **El Chispa:** uno de los 12 (por semilla) es el que cortó la luz. No se esconde ni va al portón: anda cerca del
   tablero para que nadie lo arregle, y si alguien pone un fusible sin que él esté esposado, a los 10 s lo saca y lo
   tira en la oscuridad. Se lo reconoce porque a veces le salen chispas de los dedos (se ven aunque no lo alumbren).
   Esposado, el fusible que tiene se le cae al piso. Llevarlo a la celda de castigo (la del motín) da el extra.
9. **Cuando vuelve la luz:** se prenden todas las lámparas, las celdas se traban solas con los presos que estén adentro
   y los que quedaron sueltos se rinden y se sientan donde están ("Qué aburrido con luz"). El caso se gana.
10. **El sueldo:** 600, 75 menos por cada preso escapado, 100 más si El Chispa terminó en la celda de castigo. Cuota
    propia de 400, como el motín. Sin tiempo límite (decisión 66): la presión la ponen los que van al portón.

## Lo que cambia con la semilla
Qué presos se esconden, cuáles pasean y cuáles van al portón (siempre al menos 3 al portón), dónde se esconden, dónde
están los dos fusibles sueltos, quién es El Chispa y sus frases. Así no hay dos cortes de luz iguales.

## Lo que se reusa
- La cárcel, el pabellón con 4 celdas de cada lado, la celda de castigo y la escolta (`PrisonLevel`, `PrisonEscort`).
- Los presos del motín (`PrisonInmate`, modelo `npc_preso`), las esposas y E para esposar.
- La linterna (`Flashlight`, su cono de 18 m y 22°) y la noche de la fuga.
- La cuenta de escapados y los 4 que hacen perder, del traslado (decisión 105).
- Lo nuevo: las luces apagadas en la cárcel, los ojos en la oscuridad, congelar con la luz, las rejas que se cierran a
  mano, el tablero con los fusibles y El Chispa.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. La cárcel a oscuras: `--prison=blackout`, lámparas apagadas, de noche, las velas de los guardias en el patio y las
   rejas del pabellón abiertas que se cierran a mano con E.
3. Los presos sueltos: 12 que salen del pabellón y se esconden, pasean o van al portón; los ojos en la oscuridad;
   congelarse con la linterna; escaparse por el portón.
4. Esposarlos, llevarlos a las celdas y que se queden adentro con la reja cerrada.
5. El tablero, los fusibles y El Chispa; volver la luz.
6. El caso: el comisario, la planilla, el sueldo, la cuota, perder con 4 escapados y el sorteo en Jugar
   (`PlaceDraw.PRISONS`).
7. Online: presos congelados y escondidos, rejas, fusibles y la luz que vuelve.

## Preguntas para Cristian
1. **¿Los presos se quedan duros cuando los alumbra una linterna** y se mueven a oscuras ("luz roja, luz verde")?
   Recomendado: sí, así la linterna es la herramienta del caso y hay que repartirse entre alumbrar y esposar.
2. **¿Se gana al volver la luz** con los 3 fusibles (uno lo tiene El Chispa, el que la cortó) y se pierde con 4
   escapados por el portón? Recomendado: sí, así hay dos tareas a la vez: cuidar el portón y buscar los fusibles.
3. **¿Las linternas se gastan** (60 s de pila y pilas de repuesto en la cocina)? Recomendado: no por ahora, ya alcanza
   con la oscuridad; queda en "Para después" si en la partida resulta fácil.

## Hecho así
- **Paso 2 (la cárcel a oscuras):** `--place=blackout` abre `scenes/levels/prison_blackout.tscn`, la misma cárcel
  (`PrisonLevel`, `variant = "blackout"`) de noche, con la luna y la ciudad de noche como en la fuga. Las 16 lámparas
  del techo están apagadas (`PrisonLevel.set_lights`), la reja del pabellón está abierta y cada una de las 8 celdas
  tiene su reja (`CellDoor`) en el medio del frente, abierta hacia adentro de la celda para no tapar el pasillo; E la
  cierra y la abre a mano. Dos
  guardias (modelo del carcelero) tiemblan en el patio junto al portón con una vela que titila. `cell_at` dice en qué
  celda está un punto (0 a 3 al oeste, 4 a 7 al este). No hay motín ni caso todavía. Capturas en
  `/mnt/project-files/corte-de-luz/paso2-*.png`.
