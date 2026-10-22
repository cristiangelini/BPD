class_name DonutBox
extends Grabbable

## A box of donuts from the armory (docs/diseno/comisaria.md): E with the box in hand eats one, which fills the stamina
## to run, and leaves the mouth too full to ask anything (R) for a while. The last donut leaves an empty box.

const DONUTS := 4

@export var donuts := DONUTS


func _ready() -> void:
	add_to_group("donut_boxes")


## Takes one donut out of the box. Returns false if it was empty.
func eat_one() -> bool:
	if donuts == 0:
		return false
	donuts -= 1
	var donut := find_child("donut_%d" % donuts, true, false) as Node3D
	if donut:
		donut.hide()
	return true


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_DONUT_BOX" if donuts > 0 else "PROMPT_DONUT_EMPTY"
