# BPD · Allanamiento (caso 1.1 "La casa del abuelo")

Es la meta de la semana 1 (decisión 64, issue #2): un caso jugable de punta a punta con cajas grises, de 1 a 4 jugadores por Steam con voz. Los valores marcados con **(propuesta)** son míos y se ajustan jugando. Las preguntas abiertas están al final.

## El turno de la semana 1
1. **Comisaría:** aparecen los 4 en la comisaría (una sala gris con la armería y el patrullero en la puerta). El comisario (una caja con cartel) da el caso con un texto: "Allanamiento en la casa del abuelo. Traigan la evidencia. Rápido y sin romper nada."
2. **Armería:** cada policía elige hasta 4 herramientas (decisión 35). En la semana 1 hay 2: **ariete** y **linterna**. Las demás llegan con sus casos.
3. **Patrullero:** suben los 4 (o los que estén) y el viaje es automático, con un fundido de 3 s **(propuesta)**. Manejar llega con la persecución.
4. **Allanamiento:** la casa, con la orden judicial y su tiempo límite.
5. **Vuelta:** suben al patrullero con la evidencia y vuelven a la comisaría.
6. **Cuota:** pantalla del turno, con la plata, las multas, los premios en chiste (decisión 41) y si llegaron a la cuota.

## La casa del abuelo
- Casa de dos pisos, de unos 12 × 10 m de planta, con 8 ambientes: entrada, living, cocina, comedor y baño abajo, y dos dormitorios y un altillo arriba. La escalera es angosta (1,0 m).
- Hay unos 150 adornos frágiles (figuritas de porcelana, platos, jarrones), repartidos en estantes, mesas y vitrinas. Son el chiste del caso: cualquier golpe los rompe.
- La puerta de entrada está cerrada. Se abre con el **ariete** (3 golpes) o buscando la llave escondida en una de 3 macetas de afuera, elegida al azar.

## La evidencia
- **Evidencia principal:** una lata de galletas llena de "cosas sospechosas". Pesa 3 kg y vale 1000.
- **Evidencia extra:** 3 objetos opcionales que suman plata. Una caja fuerte chica de 40 kg (hacen falta 2 policías), que vale 600. Un álbum de fotos de 1 kg, que vale 200. Una figurita "distinta" escondida entre las otras, de 0,3 kg, que vale 300.
- **Al azar en cada partida** (decisión 19): dónde está cada evidencia, entre 10 escondites posibles (abajo de la cama, dentro del horno, detrás de un cuadro, en el altillo...), y en qué maceta está la llave.
- **Fragilidad (como R.E.P.O.):** cada golpe por encima de 3 m/s le saca valor a la evidencia, en proporción a la fuerza del golpe. Si llega a 0, se rompe y no cuenta.
- **Adornos rotos:** cada uno es una multa de 20 que se descuenta del sueldo del caso.

## Orden judicial y tiempo
- Tiempo límite: 6 minutos desde que el patrullero llega a la casa **(propuesta)**. Se ve en un reloj en la pantalla.
- A los 5 minutos suena un aviso por la radio: "¡Les queda un minuto!".

## Entrega
- La evidencia se entrega dejándola en el baúl del patrullero y cuenta en el momento (decisión 60).
- Cuando la evidencia principal está entregada y todos los policías en pie suben al patrullero, el caso termina.

## Cómo se gana y cómo se pierde
- **Caso resuelto:** la evidencia principal llega al baúl antes de que se acabe el tiempo.
  - Pago = 500 de sueldo + el valor que le quede a cada evidencia entregada − las multas **(propuesta)**.
- **Caso fallado:** se acaba el tiempo sin la evidencia principal en el baúl, o la evidencia principal se rompe. No cobran sueldo, pero las multas se descuentan igual.
- **Cuota del turno (semana 1, un solo caso):** 800 **(propuesta)**. Si llegan, aparece "¡Turno aprobado!". Si no, "Suspendidos": la fuga de la comisaría (decisión 17) llega más adelante y por ahora es solo la pantalla.

## Desmayo
- Un policía se desmaya si se cae de más de 4 m, si le pega un objeto pesado lanzado (más de 10 kg a más de 5 m/s) o si un compañero le pega con el ariete (fuego amigo, decisión 37).
- Queda en el piso con el cuerpo flojo (ragdoll). Un compañero lo levanta mirándolo y manteniendo E durante 2 s, o lo puede cargar como un objeto de 80 kg.
- Si nadie lo levanta en 30 s, se lo lleva la ambulancia: vuelve a la comisaría y paga una multa de 100 (decisión 38).

## Herramientas de la semana 1
- **Ariete:** se mantiene clic izquierdo para cargar el golpe y se suelta para pegar. La puerta se rompe con 3 golpes. Si el golpe no le pega a nada, el que lo usa se tambalea 1 s. Pesa 15 kg, así que se camina más lento.
- **Linterna:** se prende y se apaga con F. La casa está a media luz.

## Controles
| Acción | Tecla |
|---|---|
| Moverse | WASD |
| Mirar | mouse |
| Correr / Agacharse / Saltar | Shift / Ctrl / Espacio |
| Agarrar (mantener) y soltar | clic izquierdo |
| Tirar lo que se tiene agarrado | clic derecho |
| Acercar o alejar lo agarrado | rueda del mouse |
| Usar, abrir o levantar a un compañero | E |
| Elegir herramienta | 1 a 4 |
| Linterna | F |
| Hablar por la radio (a todos, con interferencia) | mantener T |
| Ver plata, tiempo y cuota | Tab |

- La voz es siempre abierta con detección de voz y se escucha por cercanía (decisión 9) **(propuesta)**. Habrá una opción de pulsar para hablar.
- Todas las teclas se pueden cambiar en Opciones.

## Red
- Host con autoridad: simula la física de los objetos, el tiempo, la plata y la evidencia. Cada jugador mueve su propio cuerpo para que no haya demora al caminar (decisión 50).
- Lo agarrado lo simula el host. El que agarra manda hacia dónde mira y el host mueve el objeto.
- Se mide en la primera prueba online: si los objetos agarrados se sienten con demora, se prueba darle la autoridad del objeto al que lo agarra.

## Panel de debug (solo en desarrollo)
- Saltar a la comisaría, a la casa o a la pantalla de la cuota.
- Tiempo infinito.
- Mostrar dónde está la evidencia.
- Sumar plata.

## Pruebas (GUT)
- La fragilidad: un golpe por debajo de 3 m/s no saca valor y uno fuerte sí, en proporción.
- El pago: sueldo + valor − multas, el caso fallado y la cuota.
- El sorteo: la evidencia cae siempre en un escondite válido y la misma semilla da el mismo sorteo en todos los jugadores.
- Las cargas entre varios: un objeto de 40 kg no se levanta con 1 policía y sí con 2.
- El desmayo: por caída de más de 4 m, y la ambulancia a los 30 s.
- La red: host y cliente conectados sin ventana ven el mismo resultado del caso.

## Fuera de la semana 1 (van a "Para después")
- El abuelo como NPC, manejar el patrullero, la prensa, las coimas, más herramientas, las otras 9 variantes de allanamiento y los cosméticos.

## Preguntas abiertas
1. ¿6 minutos de tiempo límite? (propuesta: sí)
2. ¿Viaje automático en el patrullero esta semana? (propuesta: sí)
3. ¿Voz siempre abierta o pulsar para hablar? (propuesta: abierta, con la otra como opción)
4. ¿Sueldo de 500, cuota de 800 y multa de 20 por adorno? (propuesta: sí)
5. ¿El abuelo queda para la semana 2? (propuesta: sí)
