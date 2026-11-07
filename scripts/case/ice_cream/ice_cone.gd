class_name IceCone
extends Grabbable

## A cone of ice cream from the shop's dispenser (docs/diseno/allanamiento-heladeria.md, "Lucho"): E with it on Lucho
## the delivery boy buys what he saw.

const CONE := Color(0.85, 0.6, 0.3)
const SCOOP := Color(0.98, 0.62, 0.75)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.1


## Made in code: a guest copies it from this script (PropSync).
func net_setup() -> Dictionary:
	return {}


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.14, 0.26, 0.14)
	shape.shape = box
	add_child(shape)
	var cone := MeshInstance3D.new()
	var tip := CylinderMesh.new()
	tip.top_radius = 0.045
	tip.bottom_radius = 0.0
	tip.height = 0.16
	tip.radial_segments = 8
	cone.mesh = tip
	cone.position.y = -0.04
	cone.material_override = _material(CONE)
	add_child(cone)
	var scoop := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.055
	ball.height = 0.11
	ball.radial_segments = 8
	ball.rings = 5
	scoop.mesh = ball
	scoop.position.y = 0.07
	scoop.material_override = _material(SCOOP)
	add_child(scoop)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
