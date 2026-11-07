class_name ShelfToy
extends Grabbable

## A toy taken off a shelf of the toy store (docs/diseno/allanamiento-jugueteria.md, "Doña Ramona"): a little robot in
## a box. E with it on doña Ramona solves one of her 14 gifts, and she tells what she saw.

const SIZE := Vector3(0.22, 0.28, 0.16)
const COLORS: Array[Color] = [Color(0.91, 0.29, 0.23), Color(0.95, 0.76, 0.19), Color(0.23, 0.54, 0.91),
	Color(0.3, 0.72, 0.4), Color(0.85, 0.4, 0.7)]

var color := COLORS[0]


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.3


## Made in code: a guest copies it from this script (PropSync).
func net_setup() -> Dictionary:
	return {}


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	_part(Vector3.ZERO, SIZE, color)
	_part(Vector3(0, 0.02, SIZE.z / 2), Vector3(0.14, 0.16, 0.01), Color(0.85, 0.92, 0.98))
	_part(Vector3(0, 0.03, SIZE.z / 2 + 0.01), Vector3(0.08, 0.1, 0.01), Color(0.72, 0.74, 0.78))


func _part(at: Vector3, size: Vector3, part_color: Color) -> void:
	var look := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	look.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = part_color
	look.material_override = material
	look.position = at
	add_child(look)
