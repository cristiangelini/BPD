class_name BlueStamp
extends StaticBody3D

## La Vaquita Azul (escena-correo.md, "La historia"): the city's first stamp, a blue square with a white cow drawn upside
## down, in a plastic sleeve the size of a book so nobody loses it. Found in its hiding spot, it lies flat on the floor
## until a cop takes it back to its frame with E (PostOffice.reveal_loot). Every number here is (propuesta).

const SIZE := Vector2(0.3, 0.36)
const BLUE := Color(0.2, 0.4, 0.85)
const SLEEVE := Color(0.9, 0.95, 1.0, 0.35)

var post_office: PostOffice


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE.x + 0.1, SIZE.y + 0.1, 0.1)
	shape.shape = box
	add_child(shape)
	_box(Vector3.ZERO, Vector3(SIZE.x, SIZE.y, 0.01), BLUE)
	var sleeve := _box(Vector3.ZERO, Vector3(SIZE.x + 0.04, SIZE.y + 0.04, 0.02), SLEEVE)
	(sleeve.material_override as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# The cow, upside down: a white body, the head below it and four legs up.
	var white := Color(0.97, 0.97, 0.95)
	_box(Vector3(0, 0.02, 0.008), Vector3(0.16, 0.09, 0.005), white)
	_box(Vector3(0.09, -0.05, 0.008), Vector3(0.06, 0.05, 0.005), white)
	for x: float in [-0.06, -0.03, 0.03, 0.06]:
		_box(Vector3(x, 0.1, 0.008), Vector3(0.015, 0.06, 0.005), white)


## Lying flat on the floor at `at`, face up.
func lie(at: Vector3) -> void:
	position = at + Vector3(0, 0.03, 0)
	rotation = Vector3(-PI / 2, 0, 0)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_STAMP_RETURN"


func use(_cop: Cop) -> void:
	if post_office:
		post_office.reveal_loot()


func _box(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	var box := MeshInstance3D.new()
	box.mesh = mesh
	box.material_override = material
	box.position = at
	add_child(box)
	return box
