class_name Drawer
extends Grabbable

## A drawer of a Dresser (investigacion.md, "Por qué se rompen las cosas", decision 76): there's no button to open it.
## A cop grabs it with left click and pulls it out by walking back slowly. Yanked too fast, it comes off its rails
## and whatever is inside flies out.

signal ripped(at: Vector3)

## How far it slides out, in meters (propuesta).
const TRAVEL := 0.4
## Pulling it, once fully open, with the hand going back faster than this rips it out (propuesta):
## crouching back (2 m/s) is safe, walking back (4 m/s) isn't.
const RIP_SPEED := 2.5
## The contents fly out at this share of the drawer's speed, plus a hop.
const SPILL_SHARE := 1.3
const SPILL_UP := 1.5

## Set by attach(): the way it slides out and its closed position.
var out_dir := Vector3.BACK
var closed_at := Vector3.ZERO
## Things put inside by the Dresser.
var contents: Array[RigidBody3D] = []
var is_ripped := false
## Hold points of last frame, to know how fast each hand pulls.
var _last_points := {}


func prompt_key(_cop: Cop) -> String:
	return "" if is_ripped else "PROMPT_DRAWER"


## How far out it is, from 0 (closed) to TRAVEL.
func opening() -> float:
	return (global_position - closed_at).dot(out_dir)


## Puts it on its rails: it only slides along `out` (a world axis), from where it is now up to TRAVEL out.
func attach(out: Vector3) -> void:
	out_dir = out.normalized()
	closed_at = global_position
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	axis_lock_linear_x = absf(out_dir.x) < 0.5
	axis_lock_linear_y = true
	axis_lock_linear_z = absf(out_dir.z) < 0.5


## The rails: past either end it stops, unless it hits the far end too fast and comes off.
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if is_ripped:
		return
	var along := (state.transform.origin - closed_at).dot(out_dir)
	var speed := state.linear_velocity.dot(out_dir)
	if along < 0.0 or along > TRAVEL:
		state.transform.origin -= out_dir * (along - clampf(along, 0.0, TRAVEL))
		state.linear_velocity -= out_dir * speed


func _physics_process(delta: float) -> void:
	super(delta)
	var pull := 0.0
	for id: int in holders:
		if _last_points.has(id):
			pull = maxf(pull, (holders[id] - _last_points[id]).dot(out_dir) / delta)
	_last_points = holders.duplicate()
	if not is_ripped and opening() >= TRAVEL - 0.02 and pull > RIP_SPEED:
		rip(pull)


## Comes off the rails: the drawer keeps going and the contents fly out ahead of it.
func rip(speed: float) -> void:
	if is_ripped:
		return
	is_ripped = true
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false
	axis_lock_linear_x = false
	axis_lock_linear_y = false
	axis_lock_linear_z = false
	linear_velocity = out_dir * speed
	var rng := RandomNumberGenerator.new()
	rng.seed = get_instance_id()
	for item in contents:
		if is_instance_valid(item) and item.global_position.distance_to(global_position) < 0.6:
			var side := out_dir.cross(Vector3.UP) * rng.randf_range(-1.0, 1.0)
			item.sleeping = false
			item.linear_velocity = out_dir * speed * SPILL_SHARE + Vector3.UP * SPILL_UP + side
	ripped.emit(global_position)
