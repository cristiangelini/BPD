class_name RcRemote
extends Evidence

## The Titiritero's remote control (control-auto-fantasma.md, "Cómo es", step 7): it falls out of his hands when he's
## cuffed. In the patrol car's trunk it's +100 on a solved case (TrafficCase), like the fruit truck's gold watch, and
## just as tough: no hit takes its value off.

const MODEL := preload("res://assets/models/rc_remote.glb")
const KG := 0.4
const VALUE := 100.0
## Bigger than a real one, so it reads on the ground.
const LOOK_SCALE := 1.5


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	full_value = VALUE
	safe_speed = INF
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.22, 0.08, 0.13) * LOOK_SCALE
	shape.shape = box
	shape.position.y = box.size.y / 2 - 0.025 * LOOK_SCALE
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * LOOK_SCALE
	add_child(model)


func _ready() -> void:
	super._ready()
	add_to_group("rc_remotes")


## Online (PropSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_RC_REMOTE"
