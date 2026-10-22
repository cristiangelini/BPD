class_name LooseDonut
extends Grabbable

## A donut taken out of the guard's box in the jailbreak (fuga.md, step 3): E with it in hand breaks it in two. The one
## with the key lets it fall into the cop's hands; any other one gets eaten, like a donut from the armory.

const MODEL := preload("res://assets/models/donut.glb")
const KEY_SCENE := preload("res://scenes/props/cell_key.tscn")

var has_key := false


func _ready() -> void:
	# The guard gets suspicious if he sees one of his donuts out of the box (NightGuard).
	add_to_group("guard_clues")
	mass = 0.1
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.08
	cylinder.height = 0.05
	shape.shape = cylinder
	add_child(shape)
	add_child(MODEL.instantiate())


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_BREAK_DONUT"


## Breaks it: the key into the cop's hands, or the donut into the cop's mouth.
func use(cop: Cop) -> void:
	if has_key:
		var key: CellKey = KEY_SCENE.instantiate()
		get_parent().add_child(key)
		key.global_position = global_position
		cop.get_node("Grabber").grab(key)
		cop.show_hint("HINT_KEY_IN_DONUT")
	else:
		cop.get_node("Grabber").release()
		cop.fill_up_on_donut()
		cop.show_hint("HINT_DONUT_NO_KEY")
	queue_free()
