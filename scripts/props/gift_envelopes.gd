class_name GiftEnvelopes
extends Evidence

## The wedding's gift envelopes El Colado took (control-boda.md, "Cómo es", steps 6 and 7): they're in his car's trunk,
## and once he's cuffed they're on its lid. In the patrol car's trunk they're +100 on a solved case (TrafficCase), like
## the fruit truck's gold watch, and just as tough: no hit takes its value off.

const MODEL := preload("res://assets/models/gift_envelopes.glb")
const KG := 0.5
const VALUE := 100.0
## Bigger than real ones, so they read on the ground.
const LOOK_SCALE := 1.6


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	full_value = VALUE
	safe_speed = INF
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.24, 0.09, 0.15) * LOOK_SCALE
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * LOOK_SCALE
	add_child(model)


func _ready() -> void:
	super._ready()
	add_to_group("gift_envelopes")


## Online (PropSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_GIFT_ENVELOPES"
