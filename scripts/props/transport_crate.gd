class_name TransportCrate
extends Grabbable

## The cat's transport crate in the mansion's hall (escena-gato.md, "Agarrar una gata"). A cat held up to its door goes
## in and can't jump out; one or two cops carry it. E on it opens the door and lets her out. Every number here is
## (propuesta).

const SIZE := Vector3(0.5, 0.42, 0.7)
## How close to the door a held cat has to be to go in.
const DOOR_REACH := 0.75
const SHELL := Color(0.85, 0.82, 0.75)
const GRILLE := Color(0.3, 0.3, 0.32)

var cat: MansionCat


func _ready() -> void:
	add_to_group("transport_crates")
	collision_layer = 4
	collision_mask = 15
	mass = 6.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_box(Vector3(0, SIZE.y / 2, -0.03), SIZE - Vector3(0, 0, 0.06), SHELL)
	_box(Vector3(0, SIZE.y + 0.03, 0), Vector3(0.08, 0.06, 0.3), GRILLE)
	for i in 5:
		_box(Vector3(-0.16 + i * 0.08, SIZE.y / 2, SIZE.z / 2 - 0.02), Vector3(0.02, SIZE.y - 0.08, 0.02), GRILLE)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CAT_CRATE_OPEN" if cat else "PROMPT_CAT_CRATE"


func use(_cop: Cop) -> void:
	if cat:
		let_out()


## Where the door is, in the world.
func door() -> Vector3:
	return to_global(Vector3(0, SIZE.y / 2, SIZE.z / 2))


func put_in(it: MansionCat) -> void:
	it.free_from_arms()
	cat = it
	it.crate = self
	it.freeze = true
	it.collision_layer = 0
	it.collision_mask = 0


func let_out() -> void:
	var it := cat
	cat = null
	it.crate = null
	it.global_position = to_global(Vector3(0, 0.05, SIZE.z / 2 + 0.35))
	it.collision_layer = 4
	it.collision_mask = 15
	it.freeze = false


func _physics_process(delta: float) -> void:
	super(delta)
	if cat:
		cat.global_transform = global_transform * Transform3D(Basis(), Vector3(0, -0.01, 0.03))
		return
	for node in get_tree().get_nodes_in_group("mansion_cats"):
		var it := node as MansionCat
		if it.is_held() and not it.crate and it.global_position.distance_to(door()) < DOOR_REACH:
			put_in(it)
			return


func _box(at: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = size
	mesh.mesh = cube
	mesh.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	add_child(mesh)
