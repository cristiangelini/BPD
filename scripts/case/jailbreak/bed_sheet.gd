class_name BedSheet
extends Grabbable

## The folded sheet on a cell's bunk in the roof jailbreak (docs/diseno/fuga-techo.md): two per bunk, four in all, the rope (step 3).

const MODEL := preload("res://assets/models/bed_sheet.glb")
const SIZE := Vector3(0.4, 0.06, 0.3)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.6
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	add_to_group("bed_sheets")
