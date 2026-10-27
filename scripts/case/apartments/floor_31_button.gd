class_name Floor31Button
extends ClueSpot

## The "31" button in the Las Palomas elevator (edificio.md, "El piso 31"): taped over, so E only looks at it (the
## story's clue, on the checklist once). Once the floor key turns in the keyhole the tape comes off and E takes the
## car up to the machine room, the floor that doesn't exist.

var rig: Floor31Rig


func prompt_key(_cop: Cop) -> String:
	if not rig.opened:
		return prompt
	var elevator := rig.tower.elevator
	return "" if elevator.moving or elevator.at_stop == Floor31Rig.SECRET_STOP else "PROMPT_ELEVATOR_31"


func use(cop: Cop) -> void:
	if rig.opened:
		rig.tower.elevator.send(Floor31Rig.SECRET_STOP)
	else:
		super.use(cop)
