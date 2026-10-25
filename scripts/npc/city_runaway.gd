class_name CityRunaway
extends CharacterBody3D

## Someone running from the police through the city (ciudad-viva.md, step 7): the purse snatcher. They run a route
## along the streets to a dead-end alley, climb its fence faster than a cop and hide at the end, trapped. They run in
## bursts, so a cop who keeps up catches them. Cuffed, it's over. Left alone too long at the end of the alley, they
## climb the wall and get away. Every number here is (propuesta).

signal caught
signal got_away

enum State { RUN, CLIMB, TRAPPED, CAUGHT, GONE }

const RUN_SPEED := 6.0
const JOG_SPEED := 3.5
## Seconds of running, then of jogging to catch their breath.
const RUN_FOR := 8.0
const JOG_FOR := 3.0
const REACH := 0.8
## Climbing takes them this share of a cop's time.
const CLIMB_SHARE := 0.6
## Seconds trapped at the end before they get away over the wall.
const TRAPPED_FOR := 60.0
const MODEL := preload("res://assets/models/npc_sospechoso.glb")

var state := State.RUN
## Their route: points on the ground, in the world, in order.
var route := PackedVector3Array()
var next := 0
var _burst := 0.0
var _climb := {}
var _climb_from := Vector3.ZERO
var _climb_left := 0.0
var _trapped_left := TRAPPED_FOR
var _cuffed_left := 0.0


func _ready() -> void:
	add_to_group("city_runaways")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	add_child(MODEL.instantiate())


## The route from `from` to the end of `alley` ([block, side], CityLife.ALLEYS): onto the street, along the streets
## to the one in front of the alley, into it, to its fence, over it and to the wall.
static func route_to(from: Vector3, alley: Array) -> PackedVector3Array:
	var block: Vector2i = alley[0]
	var normal := CityLayout.side_normal(alley[1])
	var mouth := CityLayout.block_center(block) + normal * (CityLayout.BLOCK / 2 - CityLayout.SIDEWALK)
	var outside := mouth + normal * (CityLayout.SIDEWALK + CityLayout.STREET / 2)
	var start := _onto_street(from)
	# Along the street it's on to its nearest crossing, then along the grid.
	var corner_a := Vector3(_nearest_street(start.x, true), 0, _nearest_street(start.z, false))
	var corner_b := Vector3(outside.x, 0, _nearest_street(outside.z, false))
	var points: Array[Vector3] = [start, corner_a, Vector3(corner_b.x, 0, corner_a.z), corner_b, outside, mouth,
		mouth - normal * (CityLife.ALLEY_LENGTH - 6.0 - 1.0), mouth - normal * (CityLife.ALLEY_LENGTH - 1.0)]
	var clean := PackedVector3Array()
	for p in points:
		if clean.is_empty() or clean[clean.size() - 1].distance_to(p) > 0.5:
			clean.append(p)
	return clean


## `route` (in the city's space) in the world, for a city placed at `city`.
static func in_world(route: PackedVector3Array, city: Transform3D) -> PackedVector3Array:
	var world := PackedVector3Array()
	for p in route:
		world.append(city * p)
	return world


## The nearest point on the middle of a street.
static func _onto_street(at: Vector3) -> Vector3:
	var x := _nearest_street(at.x, true)
	var z := _nearest_street(at.z, false)
	return Vector3(at.x, 0, z) if absf(at.z - z) < absf(at.x - x) else Vector3(x, 0, at.z)


static func _nearest_street(at: float, columns: bool) -> float:
	var best := INF
	for k in (CityLayout.COLUMNS if columns else CityLayout.ROWS) + 1:
		var line := CityLayout.street_x(k) if columns else CityLayout.street_z(k)
		if absf(line - at) < absf(best - at):
			best = line
	return best


## The handcuffs: caught.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if state != State.CAUGHT and state != State.GONE:
		state = State.CAUGHT
		caught.emit()


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	match state:
		State.RUN:
			_run(delta)
		State.CLIMB:
			_climb_left = maxf(_climb_left - delta, 0.0)
			var time := Climbable.CLIMB_TIME * CLIMB_SHARE
			global_position = Climbable.along(_climb_from, _climb, 1.0 - _climb_left / time)
			if _climb_left <= 0.0:
				state = State.RUN
		State.TRAPPED:
			_trapped_left -= delta
			if _trapped_left <= 0.0:
				state = State.GONE
				got_away.emit()
				hide()


func _run(delta: float) -> void:
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	if next >= route.size():
		state = State.TRAPPED
		velocity = Vector3.ZERO
		return
	var to := route[next] - global_position
	to.y = 0.0
	if to.length() < REACH:
		next += 1
		return
	_burst = fposmod(_burst + delta, RUN_FOR + JOG_FOR)
	var speed := RUN_SPEED if _burst < RUN_FOR else JOG_SPEED
	var ahead := to.normalized()
	rotation.y = atan2(ahead.x, ahead.z)
	velocity.x = ahead.x * speed
	velocity.z = ahead.z * speed
	move_and_slide()
	# A curb: up it (their body is thinner than a cop's, so it doesn't ride up on its own).
	if is_on_wall() and Vector2(get_real_velocity().x, get_real_velocity().z).length() < 1.0:
		global_position.y += CityLife.CURB + 0.05
	# A fence in the way: over it.
	var climb := Climbable.find(get_world_3d().direct_space_state, global_position, ahead, [get_rid()])
	if not climb.is_empty():
		_climb = climb
		_climb_from = global_position
		_climb_left = Climbable.CLIMB_TIME * CLIMB_SHARE
		state = State.CLIMB
