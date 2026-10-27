class_name ElevatorKeyhole
extends StaticBody3D

## The keyhole under the elevator's buttons (edificio.md, "El piso 31"): with the floor key in hand, E turns it and
## the "31" button wakes up. Without it, it's just a keyhole.

var rig: Floor31Rig


func prompt_key(cop: Cop) -> String:
	if rig.opened:
		return ""
	return "PROMPT_TURN_FLOOR_KEY" if _holds_key(cop) else "PROMPT_KEYHOLE"


func use(cop: Cop) -> void:
	if rig.opened:
		return
	if _holds_key(cop):
		rig.open(cop)
	else:
		cop.show_hint("HINT_KEYHOLE_EMPTY")


func _holds_key(cop: Cop) -> bool:
	return cop.get_node("Grabber").held == rig.key
