class_name ShowroomSeat
extends StaticBody3D

## A sofa or a bed of the furniture store's showroom (docs/diseno/allanamiento-muebleria.md, "Su distracción"): E
## sits the cop on it (or lays it down) to try it out, and that's what Don Cajón can't resist: he comes to sell it.

signal tried(cop: Cop)

## "sofa" or "bed".
@export var kind := "sofa"


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRY_BED" if kind == "bed" else "PROMPT_TRY_SOFA"


func use(cop: Cop) -> void:
	cop.global_position = to_global(sit_point())
	cop.velocity = Vector3.ZERO
	tried.emit(cop)


## Where the cop ends up on it, in its own space: on the middle cushion, or on the mattress.
func sit_point() -> Vector3:
	return Vector3(0, 0.65, 0) if kind == "bed" else Vector3(0, 0.55, 0.1)


## Where a salesman stands to talk to whoever is on it, in its own space: in front of it.
func pitch_point() -> Vector3:
	return Vector3(0.9, 0, 1.4) if kind == "bed" else Vector3(0, 0, 1.2)
