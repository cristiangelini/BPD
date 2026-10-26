class_name ChaseCan
extends RigidBody3D

## A tin can off the wedding's runaway car (control-boda.md, "Cómo es", step 8): El Colado cuts them loose at every
## corner he turns and they clatter down the street behind him, light enough to bounce off the patrol car.

const KG := 0.3
const RADIUS := 0.05
const HEIGHT := 0.12
const TIN := Color(0.72, 0.74, 0.77)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = RADIUS * 2.0
	cylinder.height = HEIGHT * 2.0
	shape.shape = cylinder
	shape.rotation.x = PI / 2
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var can := CylinderMesh.new()
	can.top_radius = RADIUS * 2.0
	can.bottom_radius = RADIUS * 2.0
	can.height = HEIGHT * 2.0
	can.radial_segments = 8
	mesh.mesh = can
	var material := StandardMaterial3D.new()
	material.albedo_color = TIN
	material.metallic = 0.6
	material.roughness = 0.4
	mesh.material_override = material
	mesh.rotation.x = PI / 2
	add_child(mesh)


## Online (NpcSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}
