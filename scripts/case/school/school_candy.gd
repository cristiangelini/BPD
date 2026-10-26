class_name SchoolCandy
extends Grabbable

## A candy from the teacher's box (politico-escuela.md, step 5, decision 210): E with it on a crying pupil calms them.

const SIZE := Vector3(0.1, 0.05, 0.05)
const WRAPPER := Color(0.95, 0.4, 0.65)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.02


## Made in code: a guest copies it from this script (PropSync).
func net_setup() -> Dictionary:
	return {}


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE * 1.6
	shape.shape = box
	add_child(shape)
	var sweet := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = SIZE
	sweet.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = WRAPPER
	sweet.material_override = material
	add_child(sweet)
