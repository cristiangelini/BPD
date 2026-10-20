# La comisaría (la base entre casos)

Junta lo que ya está decidido (decisiones 15, 16, 17, 20, 21, 22, 40, 59 y 69) y propone lo que falta. Todo lo marcado
**(propuesta)** espera el OK de Cristian; las preguntas abiertas están al final.

## Qué es
La comisaría es el lugar donde empieza y termina cada turno. Es una sala más en la ciudad (ciudad.md, en el centro, con
el estacionamiento adelante): se entra caminando, sin pantalla de carga. Adentro está el comisario, que reparte los
casos, y la armería, donde se retira el equipo. Más adelante se suman las celdas, el papeleo y el tablero con hilo rojo
(decisión 20), y las mejoras de la comisaría (decisión 22).

## Cómo es un turno
1. **Aparecen en la comisaría**, en la sala de guardia, de uniforme.
2. **El comisario da el caso.** Se le habla con E en su oficina y grita la denuncia anónima del día (decisión 79): el
   lugar se marca en el mapa (M). Mientras habla, los policías miran pero no se mueven (como hoy en la casa del abuelo).
   **1 caso por turno (propuesta)**, sorteado con la semilla: lugar + historia, como ahora.
3. **Pasan por la armería** y retiran lo que van a llevar (ver abajo). El ariete se retira siempre gratis.
4. **Salen en el patrullero**, resuelven el caso y vuelven con la evidencia en el baúl.
5. **El turno termina al estacionar** en la comisaría (decisión 83): sale la pantalla del turno con el sueldo, la
   evidencia, las multas, la cuota y los premios en chiste (decisión 41).
6. Si aprobaron, se guarda la partida (decisión 16) y empieza el turno siguiente en la comisaría.

## La plata y la cuota
- **Una caja común** para los 4 **(propuesta)**: el sueldo, la evidencia y las multas de cada caso entran y salen de
  ahí. Se ve en la pantalla del turno y en el mostrador de la armería.
- **Sueldo de 500 por caso resuelto y cuota de 800** en el turno 1, como hoy (decisión 69).
- **La cuota sube 100 por turno (propuesta):** 800, 900, 1000, 1100 y 1200.
- **La cuota es una meta, no se paga (propuesta):** se aprueba si lo que juntaron en el turno llega a la cuota, y todo
  lo juntado queda en la caja para gastar en la armería. Así gastar en equipo no hace perder la cuota.
- **5 turnos por partida** (decisión 59).

## Cómo se gana y cómo se pierde
- **Se gana** aprobando los 5 turnos: pantalla de "¡Ascendidos!" con los premios de toda la partida **(propuesta)**.
- **Se pierde** si un turno no llega a la cuota: pantalla de "Suspendidos" y termina la partida **(propuesta)**. La fuga
  de la comisaría (decisión 17) reemplaza esta pantalla más adelante: en vez de terminar, quedan presos en sus propias
  celdas y tienen que escaparse para seguir.

## La armería
Un mostrador con reja y el armero (un NPC pera, con la misma estructura que todos). Se le habla con E y abre una lista:
comprar (con la plata de la caja) y retirar (lo que ya es de la comisaría). Lo comprado queda en la armería para siempre
y se guarda con la partida. Cada policía retira lo que va a llevar; lo que no vuelve en el patrullero se pierde.

Para empezar **(propuesta)**:

| Ítem | Precio | Qué hace |
|---|---|---|
| **Ariete** | gratis, siempre hay uno | Tira abajo puertas (ya existe). |
| **Caja de donas** | 30, trae 4 | Comer una dona (E con la caja en la mano) recupera toda la resistencia para correr. Con la boca llena no se puede preguntar (R) por 3 s. |
| **Linterna** | 60 | Ilumina en los lugares oscuros (sótanos, altillos) y hace brillar un poco las huellas y migas a menos de 4 m. |
| **Guantes de goma** | 120 | El que los tiene puestos rompe menos: los golpes a la evidencia frágil le sacan la mitad del valor. |
| **Carretilla** | 200 | Un solo policía lleva hasta 40 kg empujándola (el transmisor de la radio, la caja fuerte). Lenta y ruidosa: el abuelo la escucha. |

Más adelante (con los sospechosos y la cárcel): esposas, taser, megáfono, chaleco.

## El comisario
- Está en su oficina, detrás de un escritorio lleno de papeles. Grita (decisión 21).
- Reparte el caso del turno (punto 2) y no deja salir sin escucharlo: si intentan subir al patrullero sin el caso,
  grita "¡¿Adónde van?! ¡Primero el caso!".
- Sigue apareciendo por radio en el peor momento, como hoy cuando marcan mal una sospecha.

## Cómo es por dentro (propuesta)
Unos 20 × 14 m, en una planta, con estas salas: **sala de guardia** (donde aparecen, con lockers y una máquina de café),
**oficina del comisario**, **armería** (mostrador con reja), **celdas** (2, vacías por ahora), **sala del tablero**
(cerrada por ahora) y la **puerta al estacionamiento** con el patrullero. Placeholders low poly con tools/modelgen.

## Atajos del panel de pruebas
- Saltar al turno N con la caja en X.
- Abrir la armería con plata infinita.
- Terminar el turno aprobado o suspendido.

## El orden para hacerlo (un PR chico por paso)
1. La comisaría por dentro en la ciudad, y se aparece adentro.
2. El comisario da el caso en su oficina (mueve la charla que hoy pasa frente a la casa).
3. La caja común, los 5 turnos con la cuota que sube, "Suspendidos" y "¡Ascendidos!".
4. La armería: el armero, comprar y retirar, y el ariete pasa a retirarse ahí.
5. Las donas, la linterna, los guantes y la carretilla, un PR cada uno.

El guardado entre turnos (decisión 16) va en el hilo de los temas técnicos.

## Preguntas para Cristian
1. ¿1 caso por turno, o varios?
2. ¿Sueldo 500 y cuota 800 en el turno 1, subiendo 100 por turno?
3. ¿La caja común para los 4, y la cuota como meta (no se paga)?
4. ¿Está bien la lista de la armería para empezar (ariete, donas, linterna, guantes, carretilla)?
5. ¿No llegar a la cuota termina la partida ("Suspendidos") hasta que esté la fuga?
6. ¿5 turnos por partida, y al final "¡Ascendidos!"?
