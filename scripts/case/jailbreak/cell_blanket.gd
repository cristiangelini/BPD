class_name CellBlanket
extends Grabbable

## The grey blanket on a cell's bunk in the fire drill jailbreak (docs/diseno/fuga-simulacro.md, step 1). In hand, E on
## the cell's old heater (CellHeater) holds it against it and it smokes.

const MODEL := preload("res://assets/models/cell_blanket.glb")
const SIZE := Vector3(0.5, 0.1, 0.4)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 1.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	add_to_group("cell_blankets")


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_BLANKET"
