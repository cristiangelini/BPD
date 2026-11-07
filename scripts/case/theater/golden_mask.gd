class_name GoldenMask
extends StaticBody3D

## The Golden Mask (escena-teatro.md, "La historia"): the founder's mask, gold, smiling, with two eye holes. Found in
## its hiding spot, it lies on the floor until a cop takes it back to its case with E (Theater.reveal_loot). Every
## number here is (propuesta).

const SIZE := Vector3(0.26, 0.32, 0.08)

var theater: Theater


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE + Vector3(0.1, 0.1, 0.1)
	shape.shape = box
	add_child(shape)
	var face := SphereMesh.new()
	face.radius = SIZE.x / 2
	face.height = SIZE.y
	face.radial_segments = 12
	face.rings = 6
	_part(face, Vector3.ZERO, Vector3(1, 1, SIZE.z * 2 / SIZE.x), Color(0.98, 0.78, 0.25))
	# The eye holes and the smile.
	for side: float in [-1.0, 1.0]:
		_part(_box(Vector3(0.05, 0.03, 0.01)), Vector3(side * 0.055, 0.04, SIZE.z), Vector3.ONE, Theater.BLACK)
	_part(_box(Vector3(0.1, 0.02, 0.01)), Vector3(0, -0.07, SIZE.z - 0.005), Vector3.ONE, Theater.BLACK)


## Lying on its back on the floor at `at`, face up.
func lie(at: Vector3) -> void:
	position = at + Vector3(0, SIZE.z, 0)
	rotation = Vector3(-PI / 2, 0, 0)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MASK_RETURN"


func use(_cop: Cop) -> void:
	if theater:
		theater.reveal_loot()


func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


func _part(mesh: Mesh, at: Vector3, stretch: Vector3, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.2 if color != Theater.BLACK else 0.0
	material.roughness = 0.35
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	part.position = at
	part.scale = stretch
	add_child(part)
