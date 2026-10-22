class_name DonutBox
extends Grabbable

## A box of donuts from the armory (docs/diseno/comisaria.md): E with the box in hand eats one, which fills the stamina
## to run, and leaves the mouth too full to ask anything (R) for a while. The last donut leaves an empty box.
## The night guard's box in the jailbreak (fuga.md) is `loose`: E on it takes one donut out into the cop's hands
## (LooseDonut), and one of its donuts, `key_donut`, has the key of the cells baked in. Online only the host makes the
## donut and the key (PropSync copies them to the guests).

const DONUTS := 4
const KEY_SCENE := preload("res://scenes/props/cell_key.tscn")
const LOOSE_DONUT_SCENE := preload("res://scenes/props/loose_donut.tscn")

@export var donuts := DONUTS
## E on it takes a donut out instead of nothing.
@export var loose := false
## Which donut (its part donut_<n>) has the key; -1 for none.
var key_donut := -1


func _ready() -> void:
	add_to_group("donut_boxes")


## Takes the last donut out of the box: its number, or -1 if the box was empty.
func take_one() -> int:
	if donuts == 0:
		return -1
	donuts -= 1
	var donut := find_child("donut_%d" % donuts, true, false) as Node3D
	if donut:
		donut.hide()
	return donuts


## A cop eats one straight from the box in hand. Returns false if it was empty. Biting the one with the key, the key
## falls out on the floor.
func eat_one() -> bool:
	var taken := take_one()
	if taken >= 0 and taken == key_donut and multiplayer.is_server():
		var key: CellKey = KEY_SCENE.instantiate()
		get_parent().add_child(key)
		key.global_position = global_position + Vector3.UP * 0.2
	return taken >= 0


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_DONUT_BOX" if donuts > 0 else "PROMPT_DONUT_EMPTY"


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TAKE_DONUT" if loose and donuts > 0 else "PROMPT_GRAB"


## E on a loose box lying around: one donut out, into the cop's hands.
func use(cop: Cop) -> void:
	if not loose or cop.get_node("Grabber").held:
		return
	var taken := take_one()
	if taken < 0:
		cop.show_hint("HINT_DONUTS_GONE")
		return
	if not multiplayer.is_server():
		return
	var donut: LooseDonut = LOOSE_DONUT_SCENE.instantiate()
	donut.has_key = taken == key_donut
	get_parent().add_child(donut)
	donut.global_position = global_position + Vector3.UP * 0.1
	cop.handed(donut)
