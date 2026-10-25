# Infiltración: Escuela de ladrones (variante 10 de infiltracion.md)

Séptima variante de la infiltración, después del Club de abuelos, el Coro de iglesia, la Banda de mimos, la Fiesta de
disfraces y el Gimnasio (decisión 173, propuesta del 25/10). Se reusa casi todo: el lugar como `InfiltrationPlace`, la
gente que mira con su medidor (`ClubMember` y `ClubSuspicion`), el disfraz con las manos, 3 pruebas de 6 por la
semilla, el caso con la planilla y el sueldo (`InfiltrationCase.VARIANTS`), la huida con persecución si los descubren y
el sorteo de "Jugar". Lo nuevo son **las clases con nota**: hay que aprender a robar bien, porque el jefe solo aparece
en **la graduación**, para darles el diploma a los mejores alumnos. Todo lo que dice **(propuesta)** se ajusta jugando.

## La historia
La "Academia Manos Ligeras" es una escuela de ladrones que funciona en un edificio de la ciudad. La da la Profesora
Ganzúa, pero el que manda es el **Director**, que nunca se deja ver: solo baja el día de la graduación para entregar
los diplomas. Los policías se anotan como alumnos nuevos, sacan buenas notas, juntan 3 pruebas y lo esposan cuando
aparece con los diplomas.

El chiste: cuatro policías estudiando para ser buenos ladrones, sacándose un 2 en "carterista" y con la profesora
anotando en el boletín "se nota que es policía".

## Cómo es
1. **El lugar:** la "Academia Manos Ligeras", un lote nuevo de la ciudad **(propuesta)**: el aula con pupitres, el
   pizarrón y el escritorio de la profesora; el patio de prácticas con cerraduras en una pared, un muñeco con saco y
   una cancha de "sigilo" con piso que cruje; la biblioteca; y la oficina del Director arriba de una escalerita (con
   llave). Entre 8 y 10 alumnos de la banda **(propuesta)**.
2. **El disfraz:** en el casillero de la comisaría hay, por policía, un antifaz (a la cara), un gorro negro (a la
   cabeza) y una remera a rayas (al pecho): el ladrón de caricatura, como el sospechoso. Con 2 de las 3 el policía pasa
   por alumno (`is_disguised("thief")`). Con el uniforme, el portero no lo deja pasar: "¿Uniforme de policía? Muy
   gracioso. Afuera" **(propuesta)**.
3. **Las clases (lo nuevo):** a los 20 s y después cada 45 s suena el timbre y la Profesora da una clase práctica de
   15 s, por turno **(propuesta)**:
   - **ganzúa:** mantener E en una cerradura de práctica de la pared sin moverse; cada candado abierto (3 s) suma;
   - **carterista:** sacarle la billetera del bolsillo al muñeco agachado (C) y sin chocarlo; parado o chocándolo, suenan
     los cascabeles y cuenta mal;
   - **sigilo:** cruzar la cancha que cruje mientras la Profesora está de espaldas, sin correr; si da vuelta y te ve
     moviéndote, cuenta mal (como "luz verde, luz roja").
   Al final de cada clase la Profesora pone una nota del 1 al 10 a cada policía que estuvo en el aula o el patio, y se ve
   en un boletín (Q, en la planilla). Con nota de 3 o menos, los alumnos que lo ven suman +25 ("¡Qué ladrón tan
   malo!... ¿no será policía?"). Faltar a una clase estando adentro da la nota más baja.
4. **La graduación:** cuando el promedio de los policías llega a 7 en las tres materias, la Profesora anuncia la
   graduación en la clase siguiente y **el Director baja con los diplomas** al aula. Recién ahí se lo puede esposar.
   Antes, la oficina tiene llave y el Director no está **(propuesta)**.
5. **La sospecha:** la del club con otros textos: sin disfraz, con una herramienta de policía en la mano, en la
   oficina, una pieza del disfraz que se cae y las notas bajas. A 100 un alumno grita "¡Son policías! ¡Nadie roba tan
   mal!".
6. **Las 3 pruebas** (la semilla elige 3 de 6) **(propuesta)**:
   - la lista de "tareas" (las casas para robar) en el escritorio de la Profesora (se agarra);
   - foto del pizarrón con el plano del banco;
   - el registro de alumnos con sus nombres de verdad, en la biblioteca (se agarra; está detrás de un libro, E);
   - el video de dos alumnos repasando el golpe para el examen (5 s cerca con la cámara, como el club);
   - el botín de "práctica" (relojes y collares de verdad) en el baúl del patio, que tiene llave (la llave en el
     escritorio de la Profesora);
   - foto del diploma en blanco de la oficina, con la firma del Director.
7. **Se gana** esposando al Director: sueldo de 600, un tercio menos por cada prueba que falte, cuota de 400, igual que
   las otras infiltraciones. Esposar a un alumno o a la Profesora los descubre. Detenido, el turno siguiente puede ser
   su interrogatorio (decisión 93): se le escapan 3 frases y confiesa.
8. **Si los descubren:** el Director sale por atrás y escapa en el auto de práctica de la escuela, con el cartel de
   "ESCUELA DE MANEJO... DE ESCAPE" en el techo; maneja como alumno: lento (35 km/h) y cada tanto se le cala y frena 2 s
   **(propuesta)**. Si los descubren antes de la graduación, el que escapa es el mismo Director, que estaba mirando por
   la ventana de la oficina.
9. **Sin tiempo límite** (decisión 66), como las otras infiltraciones.

## Online
Todo lo decide el host, como en el gimnasio: la semilla (los alumnos, las pruebas y el orden de las clases), cuándo
suena el timbre, las notas que suma cada policía, la graduación, la sospecha de cada alumno y las pruebas. Cada PC
juzga a su policía en la clase (si abre el candado, si saca la billetera, si se movió con la Profesora mirando) y le
avisa al host, como `GymRoutine`.

## Lo que se reusa
`InfiltrationPlace` e `InfiltrationCase` (variante "school"), `ClubMember` (alumnos y la Profesora), `ClubSuspicion`
(con `prefix` "SCHOOL_"), `ClubDoorman` (el portero), `ClubEvidence` y `ClubEvidenceSpot`, `KeyPot`, `DisguisePiece`
(tres piezas nuevas), `PlaceBuilder`, `ChaseCase` con un `SuspectCar` nuevo, `PlaceDraw` y `NpcSync`. Las clases copian
la forma de `GymRoutine` (host decide, cada PC juzga y avisa).

## El orden para hacerlo (un PR chico por paso)
1. El disfraz de ladrón: antifaz, gorro y remera a rayas en una fila frente a los casilleros, y el look "thief" (2 de
   3).
   Hecho así: 12 piezas en una séptima fila a 4,4 m frente a los casilleros (antifaz negro con agujeros, gorro negro
   y remera a rayas gris y negra, distinta de la blanca y negra de los mimos). Con 2 de 3, `is_disguised("thief")`.
   Correr la hace caer como cualquier disfraz **(propuesta)**.
2. La escuela en la ciudad (`--place=school`): el aula, el patio de prácticas, la biblioteca y la oficina; los
   alumnos, la Profesora y el portero.
   Hecho así: un lote nuevo en la cuadra (4, 0), al sur, de 24 x 20 m. Desde la entrada, un hall; a la izquierda el
   aula (pizarrón en la pared oeste, el escritorio de la Profesora y 12 pupitres en 3 columnas) y a la derecha el
   patio de prácticas (4 cerraduras de práctica en la pared este, el muñeco con saco y cascabeles, y el piso de tablas
   que cruje); atrás, la biblioteca con estantes (oeste) y la oficina del Director con llave (este), con el lema "¡Lo
   que se aprende, no se devuelve!" en el pasillo. 9 alumnos (ladrón a rayas con mochila, o buzo violeta con capucha)
   en 9 de los 12 pupitres por la semilla, mirando al pizarrón; los 3 que sobran son para los policías. La Profesora
   Ganzúa (saco mostaza, anteojos, rodete con una ganzúa y una llave gigante de puntero) frente a ellos. El Director
   (frac, galera y antifaz dorado) espera en la oficina sin que se lo vea ni se lo choque. El vigía (sobretodo negro y
   binoculares) en la puerta solo deja pasar con 2 piezas de ladrón **(propuesta)**.
3. Las clases: el timbre, las tres materias, las notas, el boletín y la sospecha por notas bajas.
4. La graduación, las pruebas y el caso (variante "school"): el Director con los diplomas, las 6 pruebas, el sueldo y
   el interrogatorio.
5. La huida en el auto de práctica, el sorteo de "Jugar" en sextos y online.

## Preguntas para Cristian (decisión 173)
1. **¿El jefe solo aparece en la graduación, cuando sacan buenas notas?** Recomiendo que sí: es lo que dice el caso
   ("si sacan buenas notas, conocen al jefe") y obliga a hacer bien las clases, no solo a esconderse.
2. **¿Los policías se disfrazan de ladrón de caricatura (antifaz, gorro y remera a rayas, 2 de 3)?** Recomiendo que
   sí, para mantener la regla del disfraz y porque se lee de lejos.
3. **¿El Director escapa en el auto de práctica que se cala?** Recomiendo que sí: una persecución lenta con frenadas
   de golpe es distinta a las otras y da risa.

Mientras no respondas, se avanza con lo recomendado.
