class_name FarmCow
extends CharacterBody3D

## Margarita, Don Florencio's cow (docs/diseno/allanamiento-granja.md, "La vaca Margarita"): she grazes in her corral,
## and if its gate stays open more than PATIENCE seconds she walks out for a stroll round the farm, shoving whatever she
## bumps into. She follows a cop carrying a hay bale (anything with the "hay" meta) anywhere, through the gate if she
## has to: that's how she goes back in. Every number here is (propuesta).

signal escaped
signal returned

const MODEL := preload("res://assets/models/farm_cow.glb")
const PATIENCE := 5.0
const SPEED := 1.0
const LURE_SPEED := 1.6
const LURE_RANGE := 7.0
## She stops this far from the bale she follows.
const LURE_STOP := 1.4
const WANDER_EVERY := 5.0
const SHOVE := 2.0
## Lined up with the gate's gap within this, she walks through.
const ALIGNED := 0.6

## Her corral, the yard she strolls when out and the gate, in the farm's space (set before she's added).
var corral := Rect2()
var yard := Rect2()
var gate: FarmGate
var farm: Node3D
var rng := RandomNumberGenerator.new()
var is_out := false
var _target := Vector3.ZERO
var _wander_left := 0.0


func _ready() -> void:
	collision_layer = 8
	collision_mask = 5
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.8, 1.3, 1.8)
	shape.shape = box
	shape.position.y = 0.65
	add_child(shape)
	add_child(MODEL.instantiate())
	_target = position


## Whether `at` (the farm's space) is inside her corral.
func in_corral(at: Vector3) -> bool:
	return corral.has_point(Vector2(at.x, at.z))


## The hay bale a cop carries nearest to her, within LURE_RANGE.
func lure() -> Grabbable:
	var best: Grabbable
	var best_distance := LURE_RANGE
	for node in get_parent().get_children():
		var bale := node as Grabbable
		if not bale or not bale.has_meta("hay") or not bale.is_held():
			continue
		var d := global_position.distance_to(bale.global_position)
		if d < best_distance:
			best = bale
			best_distance = d
	return best


func _physics_process(delta: float) -> void:
	var here := position
	var inside := in_corral(here)
	if not is_out and not inside:
		is_out = true
		_wander_left = 0.0
		escaped.emit()
	elif is_out and inside and not gate.is_open:
		is_out = false
		_wander_left = 0.0
		returned.emit()
	var speed := SPEED
	var bale := lure()
	var goal := _target
	if bale:
		goal = farm.to_local(bale.global_position)
		speed = LURE_SPEED
		if Vector2(goal.x - here.x, goal.z - here.z).length() < LURE_STOP:
			goal = here
	elif inside and gate.is_open and gate.open_for > PATIENCE:
		goal = gate.position + Vector3(2.5, 0, FarmGate.WIDTH / 2)
	else:
		_wander_left -= delta
		if _wander_left <= 0.0:
			_wander_left = WANDER_EVERY * rng.randf_range(0.6, 1.4)
			var area := corral.grow(-1.2) if inside else yard
			_target = Vector3(rng.randf_range(area.position.x, area.end.x), here.y,
				rng.randf_range(area.position.y, area.end.y))
		goal = _target
	goal = _through_gate(here, goal)
	var to := goal - here
	to.y = 0.0
	var walk := to.normalized() * speed if to.length() > 0.3 else Vector3.ZERO
	velocity.x = walk.x
	velocity.z = walk.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	if walk != Vector3.ZERO:
		rotation.y = atan2(walk.x, walk.z)
	for i in get_slide_collision_count():
		var body := get_slide_collision(i).get_collider() as RigidBody3D
		if body:
			body.apply_central_impulse(walk.normalized() * SHOVE)


## Crossing the corral's fence goes through the gate: lined up with its gap she walks straight across, otherwise she
## first lines up with it on her side.
func _through_gate(here: Vector3, goal: Vector3) -> Vector3:
	if in_corral(here) == in_corral(goal) or not gate.is_open:
		return goal
	var middle := gate.position + Vector3(0, 0, FarmGate.WIDTH / 2)
	var side := -1.0 if in_corral(here) else 1.0
	if absf(here.z - middle.z) < ALIGNED:
		return middle + Vector3(-side * 2.0, 0, 0)
	return middle + Vector3(side * 1.2, 0, 0)
