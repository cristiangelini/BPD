class_name Spoon
extends Grabbable

## A dinner spoon in the spoon tunnel jailbreak (docs/diseno/fuga-tunel.md, step 1): two on each cell's tray. In hand,
## E on the cell's hole (TunnelHole) digs a scoop.

const MODEL := preload("res://assets/models/tunnel_spoon.glb")


func _ready() -> void:
	mass = 0.05
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.045, 0.02, 0.18)
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_SPOON"
