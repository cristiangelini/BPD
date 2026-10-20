class_name Grabbable
extends RigidBody3D

## A physics object cops can grab, carry together and throw (docs/diseno/escala.md, "Agarrar y cargar").
## Every holder pulls it toward their hold point with at most one cop's strength,
## so anything heavier than GameScale.COP_CARRY_KG needs several cops to lift.

const STIFFNESS := 60.0
const DAMPING := 12.0
## Spare strength over the carry limit, so a 25 kg object can still be moved, slowly.
const STRENGTH_MARGIN := 1.2

## holder id -> hold point in world space
var holders := {}
## Someone grabbed it at least once (the pigeons only take what cops left lying around).
var was_held := false
## The last holder that let go of it and when (ms), to know whose hands it flew from.
var last_holder := 0
var let_go_at := -1
## Player indexes of the cops who grabbed it, as keys: their prints are on it (PrintKit).
var touched_by := {}


static func max_force_per_holder() -> float:
	return GameScale.COP_CARRY_KG * GameScale.GRAVITY * STRENGTH_MARGIN


## Speed of a throw: 8 m/s for 1 kg, slower the heavier it is, never faster than 8 m/s.
static func throw_speed(kg: float) -> float:
	return GameScale.THROW_SPEED_1KG / sqrt(maxf(kg, 1.0))


func hold(holder_id: int, point: Vector3) -> void:
	if not holders.has(holder_id):
		var holder := instance_from_id(holder_id) as Node
		if holder and holder.get_parent() is Cop:
			touched_by[(holder.get_parent() as Cop).uniform] = true
	holders[holder_id] = point
	was_held = true
	can_sleep = false
	sleeping = false


func let_go(holder_id: int) -> void:
	holders.erase(holder_id)
	last_holder = holder_id
	let_go_at = Time.get_ticks_msec()
	if holders.is_empty():
		can_sleep = true
		sleeping = false


## The cops holding it now, plus the one who let go of it less than `since` seconds ago.
func handling_cops(since: float) -> Array[Cop]:
	var cops: Array[Cop] = []
	var ids := holders.keys()
	if let_go_at >= 0 and Time.get_ticks_msec() - let_go_at <= since * 1000.0:
		ids.append(last_holder)
	for id: int in ids:
		var grabber := instance_from_id(id) as Grabber
		if grabber and grabber.get_parent() is Cop:
			cops.append(grabber.get_parent())
	return cops


func is_held() -> bool:
	return not holders.is_empty()


func throw_toward(holder_id: int, direction: Vector3) -> void:
	let_go(holder_id)
	if is_held():
		return  # the others keep holding it, so it doesn't fly
	linear_velocity = direction.normalized() * throw_speed(mass)


func _physics_process(_delta: float) -> void:
	if holders.is_empty():
		return
	var share := 1.0 / holders.size()
	var limit := max_force_per_holder()
	for point: Vector3 in holders.values():
		var accel := (point - global_position) * STIFFNESS - linear_velocity * DAMPING
		var force := mass * accel * share + Vector3.UP * mass * GameScale.GRAVITY * share
		apply_central_force(force.limit_length(limit))
	angular_velocity *= 0.9
