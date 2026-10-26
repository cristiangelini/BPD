class_name ParadeCar
extends AnimatableBody3D

## The red convertible of deputy Lustre's parade (politico-descapotable.md, step 1, decision 222): a chauffeur at the
## wheel and the deputy standing on the back seat, waving. It drives `route` (a polyline on the ground) once, from its
## start to its end, and how far along it is follows the speech's clock (PoliticianSpeech): it waits at the start until
## the speech starts, and gets to the end when the speech ends. It never stops for anything. Forward is +Z, like the
## other vehicles. Every number here is (propuesta).

const SIZE := Vector3(2.0, 0.75, 4.4)
## Where the deputy stands, on the back seat, in the car's own space.
const SEAT := Vector3(0, 0.55, -1.0)
const TURN_RATE := 1.5
const RED := Color(0.82, 0.1, 0.12)
const CREAM := Color(0.95, 0.9, 0.78)
const CHROME := Color(0.8, 0.8, 0.82)
const GLASS := Color(0.7, 0.85, 0.95, 0.5)
const FLAGS: Array[Color] = [Color(0.25, 0.45, 0.9), Color(0.95, 0.85, 0.2)]
const CHAUFFEUR := preload("res://assets/models/npc_cliente.glb")

var route := PackedVector3Array()
var speech: PoliticianSpeech
var rider: Politician
## Meters along the route.
var along := 0.0
var _length := 0.0


func _ready() -> void:
	add_to_group("parade_cars")
	sync_to_physics = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2 + 0.2
	add_child(shape)
	_build()


## Sets it on `points` (the ground, in world space) with its rider and the clock that moves it.
func setup(points: PackedVector3Array, the_speech: PoliticianSpeech, the_rider: Politician) -> void:
	route = points
	speech = the_speech
	rider = the_rider
	_length = 0.0
	for i in route.size() - 1:
		_length += route[i].distance_to(route[i + 1])
	_place(0.0)
	rotation.y = _heading(0.0)
	_carry()


func length() -> float:
	return _length


## How far along its route it is, 0 to 1.
func progress() -> float:
	return along / _length if _length > 0.0 else 0.0


func _physics_process(delta: float) -> void:
	if route.size() < 2 or not speech:
		return
	var goal := _length * clampf(1.0 - speech.left / PoliticianSpeech.SPEECH_TIME, 0.0, 1.0)
	_place(goal)
	var turn := wrapf(_heading(along) - rotation.y, -PI, PI)
	rotation.y += clampf(turn, -TURN_RATE * delta, TURN_RATE * delta)
	_carry()


## The rider stands on the back seat, facing the way the car goes.
func _carry() -> void:
	if not rider:
		return
	rider.global_position = global_transform * SEAT
	# The deputy's model faces -Z.
	rider.rotation.y = rotation.y + PI
	rider.velocity = Vector3.ZERO


func _place(meters: float) -> void:
	along = clampf(meters, 0.0, _length)
	var left := along
	for i in route.size() - 1:
		var piece := route[i].distance_to(route[i + 1])
		if left <= piece or i == route.size() - 2:
			global_position = route[i].move_toward(route[i + 1], left)
			return
		left -= piece


## The heading (around Y, +Z forward) of the piece of the route `meters` along it.
func _heading(meters: float) -> float:
	var left := meters
	for i in route.size() - 1:
		var piece := route[i].distance_to(route[i + 1])
		if left < piece or i == route.size() - 2:
			var ahead := route[i + 1] - route[i]
			return atan2(ahead.x, ahead.z)
		left -= piece
	return rotation.y


## A low red body with a cream stripe, the windshield, two seats, the wheels, the chauffeur and a little flag on each
## front fender.
func _build() -> void:
	_box(Vector3(0, 0.55, 0), Vector3(SIZE.x, 0.55, SIZE.z), RED)
	_box(Vector3(0, 0.6, 0), Vector3(SIZE.x + 0.02, 0.08, SIZE.z + 0.02), CREAM)
	_box(Vector3(0, 0.75, 1.6), Vector3(SIZE.x - 0.1, 0.12, 1.1), RED)
	_box(Vector3(0, 1.05, 0.95), Vector3(SIZE.x - 0.2, 0.45, 0.04), GLASS, Vector3(-0.25, 0, 0))
	for z: float in [0.3, -1.3]:
		_box(Vector3(0, 0.95, z - 0.35), Vector3(SIZE.x - 0.3, 0.5, 0.12), CREAM)
	_box(Vector3(0, 0.62, 2.22), Vector3(SIZE.x - 0.2, 0.12, 0.06), CHROME)
	_box(Vector3(0, 0.62, -2.22), Vector3(SIZE.x - 0.2, 0.12, 0.06), CHROME)
	for at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = at
		add_child(wheel)
	var chauffeur: Node3D = CHAUFFEUR.instantiate()
	chauffeur.name = "Chauffeur"
	chauffeur.position = Vector3(-0.45, 0.15, 0.4)
	chauffeur.scale = Vector3.ONE * 0.85
	add_child(chauffeur)
	for i in FLAGS.size():
		var side := -1.0 if i == 0 else 1.0
		_box(Vector3(side * 0.85, 1.05, 2.0), Vector3(0.02, 0.6, 0.02), CHROME)
		_box(Vector3(side * 0.85, 1.25, 1.83), Vector3(0.02, 0.2, 0.32), FLAGS[i])


func _box(at: Vector3, size: Vector3, color: Color, rot := Vector3.ZERO) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var part := MeshInstance3D.new()
	part.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	part.material_override = material
	part.position = at
	part.rotation = rot
	add_child(part)
