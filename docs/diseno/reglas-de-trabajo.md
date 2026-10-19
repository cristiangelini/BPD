# BPD · Reglas de trabajo

Copia de las reglas de Steam 2 (Dread Warden) adaptada a BPD. Si algo choca con una costumbre de wgt o de Dread Warden, gana este archivo. Solo Cristian puede cambiarlo. Las tarjetas son issues de GitHub en el repo de BPD, sin Jira (decisión 62).

## Alcance
- **Sin meta semanal congelada** (decisión 78): cada semana se avanza lo que se pueda. Las ideas que no se hacen ahora van al issue "Para después".
- **Documento antes de programar:** ningún sistema grande se programa sin su `docs/diseno/<sistema>.md`, con reglas, números, cómo se gana, cómo se pierde y una referencia visual si hace falta. Claude hace las preguntas clave y anota las respuestas. Si algo es ambiguo, pregunta y no inventa.
- Las decisiones van numeradas en [decisiones.md](decisiones.md).

## Código y git
- Ramas `main` y `develop`. Cada cambio sale de `develop` actualizado y va en un PR a `develop`.
- Claude abre los PRs y nunca los mergea. Mergea Cristian (decisión 61).
- Un PR por tarjeta, con un solo cambio y unas 400 líneas como máximo, sin contar assets. Ningún PR espera más de 24 h. Una sesión no abre un PR nuevo mientras tenga otro pendiente de arreglos.
- Como mucho 2 sesiones de código a la vez, cada una en su propia área y en su propio worktree.
- Código, commits y PRs en inglés. Textos del juego en español neutro con "tú", siempre por `tr()` (español, inglés y portugués).

## Calidad
- Pruebas GUT sin ventana en cada PR, con una acción de GitHub desde la primera semana. Cada función nueva suma al menos una prueba. Un PR en rojo no se pide revisar.
- Chequeo visual: escenas de referencia con su captura aprobada en `tests/referencias/`. Antes de cada PR visual, Claude saca capturas y las compara. Un cambio que nadie pidió se arregla; uno pedido muestra el antes y el después.
- Claude abre el juego por su cuenta con un plugin MCP de Godot (Godot AI), probado antes en una rama.
- Panel de debug en las builds de desarrollo: saltar a cualquier caso, a la comisaría o a la cárcel, llenar la plata y desbloquear todo. Cada función nueva suma su atajo.
- Una partida real por semana con los amigos por Steam. Lo que se ve se anota en `docs/partidas/<fecha>.md`, y de esas notas salen las decisiones de la semana siguiente.
- Nunca se dice que algo anda sin una captura o la salida de una prueba. Para ver los avances, Cristian abre el juego y da el OK (decisión 57).

## Memoria del proyecto
- `CLAUDE.md` de unas 150 líneas como máximo: cómo correr el juego y las pruebas, reglas y dónde está cada cosa. El diseño va en `docs/diseno/` y el historial en el CHANGELOG.
- Skill del proyecto en `.claude/skills/bpd/`. Cada corrección de Cristian se suma como regla (la regla y por qué) en el mismo PR.

## Pedidos
- Se mandan en tanda (de 5 a 10 puntos), con números o capturas, y diciendo qué no hay que tocar.

## Qué no hacer
- Usar arte de IA como arte final.
- Hacer páginas HTML para mecánicas, mapas, efectos o HUD: todo eso se prueba directo en Godot. Las páginas quedan para cosas que no son del juego (precio, nombre, plan de Steam).
- Adoptar una herramienta sin probarla en una rama.
- Saltear pruebas.
- Crear repos, hacer push a `main` o armar builds sin que Cristian lo pida.
