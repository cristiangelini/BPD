class_name LiftCrank
extends Evidence

## The crank of the hotel's broken lift (hotel-allanamiento.md, "El ascensor de 1987"): an extra of the story, and the
## only way to open the lift. In hand, aimed at the lift's doors, E turns it (OldLift).


func held_prompt_key(cop: Cop) -> String:
	var target := cop._usable_target()
	if target is OldLift and not (target as OldLift).is_open:
		return "PROMPT_LIFT_CRANK"
	return "PROMPT_HOLDING"
