class_name CellMattress
extends Grabbable

## The cell's spare mattress in the roof jailbreak (docs/diseno/fuga-techo.md, step 1): on the bunk it lifts a cop playing alone high enough to reach the skylight.

const MODEL := preload("res://assets/models/cell_mattress.glb")
const SIZE := Vector3(0.75, 0.22, 1.8)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 8.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	add_to_group("cell_mattresses")
