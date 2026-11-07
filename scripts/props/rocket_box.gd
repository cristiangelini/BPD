class_name RocketBox
extends Evidence

## El Chispa's box of rockets (casa-equivocada.md, "Los fuegos artificiales"): the first hit harder than IGNITE_SPEED
## lights it, once. The story's rig sets off the show.

signal lit

const IGNITE_SPEED := 2.0

var is_lit := false


func hit(speed: float) -> float:
	if not is_lit and speed > IGNITE_SPEED:
		is_lit = true
		lit.emit()
	return super.hit(speed)
