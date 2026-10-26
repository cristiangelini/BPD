# BPD · Cárcel: el túnel (propuesta, 25/10)

Variante 4 de la cárcel ([carcel-motin.md](carcel-motin.md), tabla de variantes; [casos.md](casos.md), 6.4: "encontrar
el túnel antes de que terminen de cavarlo"). Usa la cárcel de la cuadra (5, 2) del motín, del corte de luz, del día de
visitas y de la lavandería. Decisión 143. Todo es **(propuesta)** hasta que Cristian responda las preguntas de abajo y
se pruebe jugando. No es la fuga del túnel con cucharas ([fuga-tunel.md](fuga-tunel.md)): ahí cavan los policías; acá
cavan los presos y los policías los buscan.

## La idea
Es hora de patio. Los presos juegan al básquet, toman sol y caminan en ronda, muy tranquilos. Demasiado tranquilos:
una banda de 3 está cavando un túnel desde una de las celdas hasta afuera del muro, y la tierra la sacan de a poco en
las botamangas del mameluco y la sueltan en el patio. El chiste: **la pista es la tierra**, y hay que seguirla hasta
la celda antes de que el túnel salga del otro lado.

## Cómo es el caso
1. **El aviso:** el comisario en su oficina: "Novatos, en la cárcel sobra tierra en el patio y falta una cuchara de
   cada tres. Alguien está cavando. Encuentren el túnel antes de que salgan".
2. **El patio:** 12 presos (el modelo del motín, mameluco naranja) en el patio: 4 juegan al básquet en el aro, 4
   caminan en ronda y 4 toman sol contra el muro. Las 8 celdas del pabellón están abiertas y vacías. Nadie se mueve
   hasta que el primer policía cruza el portón.
3. **El túnel:** sale de una de las 8 celdas (la semilla elige cuál), escondido detrás de uno de 4 escondites que
   tiene cada celda: el póster de la pared, la cucheta, el inodoro o la alfombra. El túnel avanza solo mientras
   alguien de la banda está adentro cavando: necesita 8 minutos de cavar en total. La planilla dice cuánto falta
   (en metros, de 30 m), porque el comisario lo calcula por la tierra.
4. **La banda:** los 3 de la banda se turnan: uno cava en la celda y los otros dos están en el patio. Cada 60 a 90 s
   el que cava sale al patio y otro entra a la celda. El que sale tiene las manos marrones y suelta tierra.
5. **La tierra (la pista principal):** cada preso de la banda que camina por el patio deja caer un montoncito de
   tierra cada 10 a 15 s, sacudiendo la pierna ("Qué piedrita molesta"). Los montoncitos quedan en el piso y dejan
   huellas de tierra cuando alguien pasa por encima. El que acaba de salir de cavar deja un camino de huellas de
   tierra desde su celda hasta el patio, que se borra a los 30 s.
6. **Las otras pistas:** el que cava hace ruido ("scrich, scrich") que se oye a 5 m de la celda; el preso de la
   banda que ve a un policía cerca de su celda silba de nervios y va hacia allá; y la banda nunca juega al básquet.
   Pero hay pistas falsas: el jardinero de la cárcel también tiene tierra en las manos (trabaja en las macetas del
   patio) y una celda tiene un hámster que rasca su jaula.
7. **Revisar un escondite:** E sobre el póster, la cucheta, el inodoro o la alfombra y quedarse al lado 1,5 s lo
   corre ("¿Qué hay acá atrás?"). Si no hay nada, no resta: el preso de esa celda se queja desde el patio ("¡Ey, mi
   póster!") y se perdió el tiempo.
8. **Encontrar el túnel:** detrás del escondite aparece el pozo. Si hay alguien cavando, sale y corre al portón; se
   esposa y se lleva del brazo a la celda de castigo (lo del corte de luz y la lavandería). Para cerrarlo, un
   policía trae una **bolsa de cemento** (hay 2 al lado del portón, objeto con física que se agarra) y la vacía en
   el pozo con E. Con el túnel tapado el caso se gana.
9. **La vuelta de tuerca:** cuando al túnel le faltan 5 m, la otra punta asoma afuera del muro (se ve la tierra que
   se mueve, del lado de la vereda). Si el túnel se termina, la banda sale de a uno por la otra punta, cada 15 s, y
   después cualquier preso del patio que llegue a la celda. Un policía que espera afuera en la salida los atrapa al
   asomar (E, "¡Cucú!") y el túnel todavía se puede tapar desde la celda.
10. **El final:** se gana con el túnel tapado. **Se pierde con 3 presos escapados** por el túnel.
11. **El sueldo:** 600, 100 menos por cada escapado, 25 más por cada uno de la banda en la celda de castigo, y 50
    más si el túnel se tapa antes de que asome afuera. Cuota propia de 400, como las otras cárceles.

## Lo que cambia con la semilla
En qué celda está el túnel y detrás de qué escondite, quiénes son los 3 de la banda, el orden de sus turnos, quién es
el jardinero, en qué celda está el hámster, dónde caen los montoncitos y por qué lado del muro asoma la salida.

## Lo que se reusa
- La cárcel, el pabellón con sus 8 celdas, el patio, el aro y el portón (`PrisonLevel`).
- Los presos del motín (modelo `npc_preso`), las esposas y llevarlos del brazo a la celda de castigo
  (`BlackoutEscort`), y el que corre al portón (`BlackoutInmate`, como los escondidos de la lavandería).
- E y quedarse al lado para revisar (los carritos de la lavandería).
- El pozo que crece de la fuga del túnel (`TunnelHole`) y su montaña de tierra.
- Las manchas en el piso de la fuga disfrazados de limpieza (`FloorStains`) para los montoncitos y las huellas.
- Lo nuevo: los escondites de las celdas, la banda que se turna, la tierra que cae, las huellas, el jardinero, el
  hámster, la bolsa de cemento y la salida afuera del muro.

## Atajos del panel de pruebas (cuando exista)
- Abrir la cárcel del túnel (`--place=prison_tunnel`).
- Dejar el túnel a 5 m de terminar.

## El orden para hacerlo (un PR chico por paso)
1. Este documento.
2. El túnel escondido: `--place=prison_tunnel`, los 4 escondites de cada celda, el pozo en la celda que elige la
   semilla, revisar con E 1,5 s y los 12 presos en el patio.
3. La banda: los turnos, el túnel que avanza solo mientras cavan, la tierra que cae, las huellas y el ruido.
4. Las pistas falsas (el jardinero y el hámster), el nervioso que silba y la queja por el escondite revisado.
5. Encontrarlo: el que cava sale corriendo, la bolsa de cemento que tapa el pozo, la salida que asoma afuera del
   muro, los que salen de a uno y atraparlos al asomar.
6. El caso: el comisario, la planilla, el sueldo, la cuota, perder con 3 y el sorteo en Jugar (`PlaceDraw.PRISONS`,
   en sextos con el motín, el traslado, el corte de luz, el día de visitas y la lavandería).
7. Online: los presos, los escondites, el pozo, la tierra, el cemento y el final.

## Preguntas para Cristian
Respondidas el 25/10: sí a las 3 (decisión 143).

1. **¿La tierra que tiran en el patio es la pista principal**, con las huellas que llevan hasta la celda? Recomendado:
   sí, así se busca mirando el piso y siguiendo a los presos, no revisando los 32 escondites uno por uno.
2. **¿Revisar un escondite sin nada no resta, solo cuesta tiempo** (y el preso se queja)? Recomendado: sí, el castigo
   es que el túnel sigue avanzando mientras tanto.
3. **¿Cuando el túnel se termina el caso no se pierde de una**, sino que salen de a uno por la otra punta y se pierde
   con 3 escapados? Recomendado: sí, así hay una última oportunidad esperándolos afuera del muro.
