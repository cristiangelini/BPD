class_name Pigeon
extends Node3D

## One of Marta's carrier pigeons loose in the shop (panaderia.md, "Palomas mensajeras"). It flutters around under
## the ceiling and, every now and then, swoops on something small a cop left on the floor and carries it to the top
## of the bread rack. Grabbing the thing back makes it let go. It has no body: cops can't hit it.
## Every number here is (propuesta).

## It picks up things of at most this many kg, lying this close to the floor, within this range.
const MAX_KG := 0.5
const FLOOR_BAND := 0.3
const SPOT_RANGE := 6.0
const SPEED := 3.0
## After a theft (or a failed one) it waits this long before looking again.
const REST := 6.0
const REACH := 0.25

enum State { WANDER, SWOOP, CARRY }

## Where it flutters (a box under the shop's ceiling) and where it drops what it takes, set by the rig.
var area: AABB
var perch: Vector3
var floor_y := 0.0
var state := State.WANDER
var target: Grabbable
var thefts := 0
var rng := RandomNumberGenerator.new()
var _goal: Vector3
var _rest := REST
var _flap := 0.0
var _wings: Array[Node3D] = []

const MODEL := preload("res://assets/models/pigeon.glb")


func _ready() -> void:
	var look: Node3D = MODEL.instantiate()
	add_child(look)
	for node in look.find_children("wing_*", "Node3D", true, false):
		_wings.append(node as Node3D)
	_goal = _wander_point()


func _physics_process(delta: float) -> void:
	_flap += delta * 14.0
	for wing in _wings:
		wing.rotation.z = sin(_flap) * 0.6 * (1.0 if wing.name == "wing_l" else -1.0)
	match state:
		State.WANDER:
			_fly_to(_goal, delta)
			if global_position.distance_to(_goal) < REACH:
				_goal = _wander_point()
			_rest -= delta
			if _rest <= 0.0:
				_rest = REST
				target = _pick_target()
				if target:
					state = State.SWOOP
		State.SWOOP:
			if not is_instance_valid(target) or target.is_held() or not _on_floor(target):
				_give_up()
				return
			_fly_to(target.global_position + Vector3.UP * 0.1, delta)
			if global_position.distance_to(target.global_position + Vector3.UP * 0.1) < REACH:
				target.freeze = true
				state = State.CARRY
		State.CARRY:
			if not is_instance_valid(target):
				_give_up()
				return
			if target.is_held():
				target.freeze = false
				_give_up()
				return
			_fly_to(perch + Vector3.UP * 0.15, delta)
			target.global_position = global_position + Vector3.DOWN * 0.12
			if global_position.distance_to(perch + Vector3.UP * 0.15) < REACH:
				target.freeze = false
				target.linear_velocity = Vector3.ZERO
				thefts += 1
				_give_up()


## Something small a cop left lying on the floor, the nearest within SPOT_RANGE.
func _pick_target() -> Grabbable:
	var best: Grabbable
	var best_distance := SPOT_RANGE
	for node in get_parent().get_children():
		var item := node as Grabbable
		if not item or item.mass > MAX_KG or not item.was_held or item.is_held() or item.freeze or not _on_floor(item):
			continue
		if not area.grow(0.5).has_point(Vector3(item.global_position.x, area.get_center().y, item.global_position.z)):
			continue
		var distance := item.global_position.distance_to(global_position)
		if distance < best_distance:
			best = item
			best_distance = distance
	return best


func _on_floor(item: Node3D) -> bool:
	return item.global_position.y - floor_y < FLOOR_BAND


func _give_up() -> void:
	target = null
	state = State.WANDER
	_goal = _wander_point()


func _fly_to(point: Vector3, delta: float) -> void:
	var way := point - global_position
	if way.length() < 0.01:
		return
	global_position += way.limit_length(SPEED * delta)
	var flat := Vector3(way.x, 0, way.z)
	if flat.length() > 0.05:
		look_at(global_position + flat, Vector3.UP, true)


func _wander_point() -> Vector3:
	return Vector3(rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y),
		rng.randf_range(area.position.z, area.end.z))
