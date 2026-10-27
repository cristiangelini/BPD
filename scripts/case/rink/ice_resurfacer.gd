class_name IceResurfacer
extends AnimatableBody3D

## The rink's resurfacer (docs/diseno/allanamiento-pista.md, "La pulidora", step 2): the button on the boards sets it
## going for RUN_SECONDS. It drives on its own round the ice along LOOP, pushing what's loose on the way and shoving a
## cop it runs into. When it stops it stays wherever it got to. Its front, the driver's seat, to +z. Every number here
## is (propuesta).

## It started a run (Doña Pirueta minds it, step 3).
signal started

const MODEL := preload("res://assets/models/ice_resurfacer.glb")
const SIZE := Vector3(1.5, 1.55, 2.8)
const RUN_SECONDS := 30.0
const SPEED := 2.5
## Its round on the ice, corner by corner (rink space), and how fast it turns at them.
const LOOP: Array[Vector3] = [
	Vector3(12.0, 0, -5.0), Vector3(-12.0, 0, -5.0), Vector3(-12.0, 0, 4.0), Vector3(12.0, 0, 4.0),
]
const TURN_SPEED := 2.5
## A cop this close in front of it gets shoved, at most once every SHOVE_EVERY seconds.
const SHOVE_REACH := 2.0
const SHOVE := 3.5
const SHOVE_EVERY := 1.0

var run_left := 0.0
var runs := 0
## How far along LOOP it has gone, in meters.
var along := 0.0
var _shoved := {}


func _ready() -> void:
	sync_to_physics = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func is_running() -> bool:
	return run_left > 0.0


func start() -> void:
	if is_running():
		return
	run_left = RUN_SECONDS
	runs += 1
	started.emit()


## The place on LOOP `meters` along it, and which way it heads there.
static func loop_at(meters: float) -> Array:
	var total := loop_length()
	var left := fposmod(meters, total)
	for i in LOOP.size():
		var a := LOOP[i]
		var b := LOOP[(i + 1) % LOOP.size()]
		var side := a.distance_to(b)
		if left <= side:
			return [a.lerp(b, left / side), (b - a).normalized()]
		left -= side
	return [LOOP[0], (LOOP[1] - LOOP[0]).normalized()]


static func loop_length() -> float:
	var total := 0.0
	for i in LOOP.size():
		total += LOOP[i].distance_to(LOOP[(i + 1) % LOOP.size()])
	return total


func _physics_process(delta: float) -> void:
	if not is_running():
		return
	run_left = maxf(run_left - delta, 0.0)
	along += SPEED * delta
	var spot: Array = loop_at(along)
	var heading: Vector3 = spot[1]
	position = Vector3(spot[0].x, position.y, spot[0].z)
	rotation.y = rotate_toward(rotation.y, atan2(heading.x, heading.z), TURN_SPEED * delta)
	_shove_cops(delta)


func _shove_cops(delta: float) -> void:
	for id: int in _shoved.keys():
		_shoved[id] -= delta
		if _shoved[id] <= 0.0:
			_shoved.erase(id)
	var front := global_basis.z
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop == null or _shoved.has(cop.get_instance_id()):
			continue
		var off := cop.global_position - global_position
		off.y = 0.0
		if off.length() > SHOVE_REACH or off.dot(front) < 0.0:
			continue
		_shoved[cop.get_instance_id()] = SHOVE_EVERY
		cop.knock_back((front + off.normalized()).normalized() * SHOVE, 0.6)
		cop.show_hint("HINT_RINK_RESURFACER_HIT")
