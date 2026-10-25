class_name GuardDog
extends StaticBody3D

## Mordisco, the station's guard dog in the guard dog's jailbreak (docs/diseno/fuga-perro.md, step 1): a huge bulldog
## with the cells' key hanging from his collar. He walks his round between the guard room and the cells room, there and
## back (ROUND, in the station's own space), stopping at each stop for STOP_MIN to STOP_MAX seconds to sniff around;
## the seed draws where he starts and how long each stop lasts. Every number here is (propuesta).

const MODEL := preload("res://assets/models/guard_dog.glb")
const WALK_SPEED := 1.6
const STOP_MIN := 4.0
const STOP_MAX := 10.0
const BUBBLE_TIME := 3.0
const SNIFF_LINES := 4
## [where, which way he faces there (0: along his walk), whether he stops]: the guard room, the cells' door, and the
## corridor in front of both cells and beside the guard's desk. He walks it there and back, so he never cuts through
## the desk.
const ROUND := [
	[Vector3(2.5, 0, 5.5), 0.0, true],
	[Vector3(5.0, 0, 6.4), 0.0, false],
	[Vector3(7.5, 0, 5.5), PI, true],
	[Vector3(13.0, 0, 5.5), PI, true],
	[Vector3(13.0, 0, 8.3), 0.0, true],
]
const WAG_SPEED := 14.0
const WAG := 0.04

## The station's lot, which ROUND is relative to.
var station := Transform3D.IDENTITY
## The stop he's walking to (or standing at) and which way along the round he goes (1 or -1).
var target := 0
var heading := 1
var wait_left := 0.0
var key_on_collar := true:
	set(value):
		key_on_collar = value
		if _key:
			_key.visible = value
var _model: Node3D
var _key: Node3D
var _tail: Node3D
var _wag := 0.0
var _bubble: Label3D
var _bubble_left := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("guard_dog")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.1
	shape.shape = capsule
	shape.rotation.x = PI / 2
	shape.position = Vector3(0, 0.4, 0)
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_key = _model.find_child("key", true, false)
	_tail = _model.find_child("tail", true, false)
	key_on_collar = key_on_collar
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## His round for this jailbreak's seed, on the station of `station_lot`: he starts at a stop drawn by the seed.
func setup_round(case_seed: int, station_lot: Transform3D) -> void:
	station = station_lot
	_rng.seed = hash(["guard dog", case_seed])
	var stops: Array[int] = []
	for i in ROUND.size():
		if ROUND[i][2]:
			stops.append(i)
	target = stops[_rng.randi_range(0, stops.size() - 1)]
	heading = 1 if target < ROUND.size() - 1 else -1
	global_transform = Transform3D(station.basis * Basis(Vector3.UP, ROUND[target][1]), station * ROUND[target][0])
	wait_left = _rng.randf_range(STOP_MIN, STOP_MAX)


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	_walk(delta)
	_wag_tail(delta)


## Where he's going now, in the world.
func goal() -> Vector3:
	return station * (ROUND[target][0] as Vector3)


func is_walking() -> bool:
	return wait_left <= 0.0


func _walk(delta: float) -> void:
	if wait_left > 0.0:
		wait_left -= delta
		if wait_left <= 0.0:
			_next_stop()
		return
	var to := goal() - global_position
	to.y = 0.0
	var step := WALK_SPEED * delta
	if to.length() > step:
		global_position += to.normalized() * step
		global_rotation.y = atan2(to.x, to.z)
		return
	global_position = Vector3(goal().x, global_position.y, goal().z)
	if not ROUND[target][2]:
		_next_stop()
		return
	if ROUND[target][1] != 0.0:
		global_basis = station.basis * Basis(Vector3.UP, ROUND[target][1])
	wait_left = _rng.randf_range(STOP_MIN, STOP_MAX)
	say("DOG_SNIFF_%d" % _rng.randi_range(0, SNIFF_LINES - 1))


## The next stop along the round, turning back at either end.
func _next_stop() -> void:
	if target + heading < 0 or target + heading >= ROUND.size():
		heading = -heading
	target += heading


func _wag_tail(delta: float) -> void:
	if not _tail:
		return
	_wag += delta * WAG_SPEED
	_tail.position.x = sin(_wag) * WAG


## Where his collar's key hangs, in the world.
func collar() -> Vector3:
	return global_transform * Vector3(0, 0.3, 0.48)


func say(text: String, seconds := BUBBLE_TIME) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Online: where he is along his round and whether the key is still on his collar (NpcSync).
func net_state() -> Variant:
	return [target, heading, wait_left, key_on_collar]


func apply_net_state(state: Variant) -> void:
	target = state[0]
	heading = state[1]
	wait_left = state[2]
	key_on_collar = state[3]
