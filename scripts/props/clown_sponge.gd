class_name ClownSponge
extends Grabbable

## A wet sponge from the bucket by the ring (escena-circo.md, "Los payasos iguales"): with it in hand, E on a clown
## scrubs his white makeup off, a bit each time (CircusClown).

const SIZE := Vector3(0.14, 0.07, 0.1)
const COLOR := Color(0.98, 0.85, 0.3)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = SIZE
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = COLOR
	material.roughness = 1.0
	mesh.material_override = material
	add_child(mesh)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_SPONGE"
