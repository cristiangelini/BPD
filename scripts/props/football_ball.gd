class_name FootballBall
extends Grabbable

## The charity match's ball (politico-futbol.md, step 2, decision 179): 450 g, it rolls and bounces. A cop kicks it with
## left click when it's at their feet (Grabber): a tap, or harder the longer they hold the click, toward where they
## look. E on it is a short pass along the ground. Grabbing it from further away is a handball (`handled`): the
## referee whistles it (step 5). `last_touch` is who touched it last (a cop, the deputy or a veteran), for the goals.
## Every number here is (propuesta).

signal kicked(by: Node3D, power: float)
## A cop picked it up with their hands.
signal handled(cop: Cop)

const MODEL := preload("res://assets/models/football_ball.glb")
const RADIUS := 0.11
const KG := 0.45
## At someone's feet: this close (m, flat), in front of them within this angle, and low.
const FEET_REACH := 1.3
const FEET_ANGLE := 70.0
const FEET_HIGH := 0.8
## A tap, a full kick (m/s) and how long the click is held for a full one (s); E's pass.
const KICK_SOFT := 7.0
const KICK_HARD := 20.0
const CHARGE := 0.8
const PASS := 6.0
## How much a kick goes up: a little always, more if the cop looks up (up to MAX_LIFT).
const LIFT := 0.12
const MAX_LIFT := 0.6

var last_touch: Node3D


func _ready() -> void:
	mass = KG
	continuous_cd = true
	linear_damp = 0.35
	angular_damp = 0.6
	collision_layer = 4
	collision_mask = 15
	var bounce := PhysicsMaterial.new()
	bounce.bounce = 0.5
	bounce.friction = 0.6
	physics_material_override = bounce
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = RADIUS
	shape.shape = sphere
	add_child(shape)
	add_child(MODEL.instantiate())


## Whether it's at `body`'s feet: close, in front of it and low.
func at_feet(body: Node3D) -> bool:
	var to := global_position - body.global_position
	var flat := Vector2(to.x, to.z)
	if flat.length() > FEET_REACH or to.y > FEET_HIGH:
		return false
	var facing := -body.global_basis.z
	return flat.length() < 0.4 or absf(Vector2(facing.x, facing.z).angle_to(flat)) < deg_to_rad(FEET_ANGLE)


## The nearest ball at `body`'s feet, if any.
static func near_feet(body: Node3D) -> FootballBall:
	for ball: Node in body.get_tree().get_nodes_in_group("football_balls"):
		if (ball as FootballBall).at_feet(body) and not (ball as FootballBall).is_held():
			return ball
	return null


func _enter_tree() -> void:
	add_to_group("football_balls")


## How fast a kick held `seconds` goes.
static func power_for(seconds: float) -> float:
	return lerpf(KICK_SOFT, KICK_HARD, clampf(seconds / CHARGE, 0.0, 1.0))


## Where a cop looking along `look` kicks it: flat ahead, lifted a little, more if they look up.
static func aim(look: Vector3) -> Vector3:
	var flat := Vector3(look.x, 0, look.z).normalized()
	return (flat + Vector3.UP * clampf(LIFT + maxf(look.y, 0.0), 0.0, MAX_LIFT)).normalized()


## `by` kicks it along `direction` at `power` m/s.
func kick(by: Node3D, direction: Vector3, power: float) -> void:
	if is_held():
		return
	sleeping = false
	linear_velocity = direction.normalized() * power
	angular_velocity = direction.cross(Vector3.UP) * -power / RADIUS * 0.3
	last_touch = by
	kicked.emit(by, power)


## E: a short pass along the ground, where the cop looks.
func use(cop: Cop) -> void:
	if not at_feet(cop) or is_held():
		return
	var look := -cop.camera.global_basis.z
	kick(cop, Vector3(look.x, 0.02, look.z), PASS)


func prompt_key(cop: Cop) -> String:
	return "PROMPT_KICK_BALL" if at_feet(cop) else "PROMPT_GRAB"


func hold(holder_id: int, point: Vector3) -> void:
	var first := not holders.has(holder_id)
	super.hold(holder_id, point)
	var grabber := instance_from_id(holder_id) as Grabber
	if first and grabber and grabber.get_parent() is Cop:
		last_touch = grabber.get_parent()
		handled.emit(grabber.get_parent())
