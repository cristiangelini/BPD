class_name CrowdedCar
extends RefCounted

## The crowded car traffic control (control-auto-lleno.md): most cars bring 1 to 4 people, but some come packed, 9 to 22
## people squashed against the windows, and the gang rides in one of them. This dresses a packed QueueCar: faces and
## hands pressed on its windows and its body sagging under the weight. Every number here is (propuesta).

const FACE := preload("res://assets/models/crowd_face.glb")
## From this many riders on, a car is packed: faces on every window.
const PACKED_FROM := 9
const PACKED := Vector2i(9, 22)
const FEW := Vector2i(1, 4)
## Without a plan, this share of the cars come packed.
const PACKED_SHARE := 0.3
## How far a packed car's body sinks on its wheels.
const SAG := 0.1
## Faces a bit bigger than life, so they read from the sidewalk.
const FACE_SCALE := 1.3
const SKINS: Array[Color] = [Color("f1c9a5"), Color("d9a37e"), Color("b07a52"), Color("8a5a3a"), Color("f5d7c0")]
const HAIRS: Array[Color] = [Color("3a2a1e"), Color("1c1a1a"), Color("c8a050"), Color("8a3a1a"), Color("b8b8b8")]
## Where faces press on a sedan's windows (TrafficCar's model), and which way each looks: the sides, the windshield
## and the back window. A packed car fills them in this order, as many as it has riders.
const SLOTS: Array[Array] = [
	[Vector3(0.99, 1.22, -0.2), PI / 2], [Vector3(-0.99, 1.22, -0.2), -PI / 2],
	[Vector3(0.99, 1.2, 0.45), PI / 2], [Vector3(-0.99, 1.2, 0.45), -PI / 2],
	[Vector3(0.99, 1.25, -0.8), PI / 2], [Vector3(-0.99, 1.25, -0.8), -PI / 2],
	[Vector3(0.35, 1.25, 0.92), 0.0], [Vector3(-0.35, 1.22, -1.22), PI],
	[Vector3(0.35, 1.2, -1.22), PI], [Vector3(-0.4, 1.3, 0.92), 0.0],
	[Vector3(0.99, 1.38, 0.1), PI / 2], [Vector3(-0.99, 1.38, -0.5), -PI / 2],
]


## How many ride in a car the plan didn't set: from its plate, so every PC agrees.
static func riders_of(plate: String) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["crowd riders", plate])
	var span := PACKED if rng.randf() < PACKED_SHARE else FEW
	return rng.randi_range(span.x, span.y)


## How many stay in when the door opens (the grandma who won't get out, the baby in the back): in a packed car 1 or 2,
## from its plate; in any other, nobody.
static func stay_in(plate: String, riders: int) -> int:
	return 1 + absi(hash(["crowd stays in", plate])) % 2 if packed(riders) else 0


static func packed(riders: int) -> bool:
	return riders >= PACKED_FROM


## Faces and hands on its windows, each in its own skin and hair, and its body sunk on its wheels.
static func dress(car: QueueCar) -> void:
	var model := car.get_node_or_null("Model") as Node3D
	if model:
		model.position.y = -SAG
	var faces := Node3D.new()
	faces.name = "Faces"
	faces.position.y = -SAG
	car.add_child(faces)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["crowd faces", car.plate])
	for i in mini(car.crowd, SLOTS.size()):
		var face: Node3D = FACE.instantiate()
		face.name = "Face%d" % i
		face.position = SLOTS[i][0]
		face.rotation = Vector3(0, SLOTS[i][1], rng.randf_range(-0.3, 0.3))
		face.scale = Vector3.ONE * FACE_SCALE
		faces.add_child(face)
		_tint(face, "skin", SKINS[rng.randi() % SKINS.size()])
		_tint(face, "hand", SKINS[rng.randi() % SKINS.size()])
		_tint(face, "hair", HAIRS[rng.randi() % HAIRS.size()])
		var hand := face.find_child("hand", true, false) as Node3D
		if hand:
			hand.visible = rng.randf() < 0.6


## As many faces on its windows as riders still inside.
static func show_inside(car: QueueCar, inside: int) -> void:
	var faces := car.get_node_or_null("Faces")
	if not faces:
		return
	for i in faces.get_child_count():
		(faces.get_child(i) as Node3D).visible = i < inside


static func _tint(model: Node, part: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for node in model.find_children("*", "MeshInstance3D", true, false):
		if node.name.begins_with(part) or node.get_parent().name == part:
			(node as MeshInstance3D).material_override = material
