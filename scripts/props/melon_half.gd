class_name MelonHalf
extends Grabbable

## Half of a split watermelon (Watermelon), cut side up: red, or brown when it was overripe.

const KG := 3.0
const MUSH_FLESH := Color(0.55, 0.4, 0.2)

var mushy := false


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.36, 0.17, 0.5)
	shape.shape = box
	shape.position.y = 0.085
	add_child(shape)


func _ready() -> void:
	var model: Node3D = Watermelon.HALF.instantiate()
	model.name = "Model"
	add_child(model)
	if mushy:
		var material := StandardMaterial3D.new()
		material.albedo_color = MUSH_FLESH
		for mesh in model.find_children("*watermelon_flesh*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).material_override = material
