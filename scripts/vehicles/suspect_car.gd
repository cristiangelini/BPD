class_name SuspectCar
extends CharacterBody3D

## The chase suspect's vehicle (persecucion.md): it drives itself along its ChaseRoute, in its lane, slowing down to
## turn at the corners, and stops when something is in the way (the patrol car cutting it off). It counts how long it
## has been stuck, which is how the cops stop it. Forward is +Z, like the patrol car. Every number here is (propuesta).

## 40 km/h on the straight, slower than the patrol car's 60, and this share of it through a sharp turn.
const SPEED := 40.0 / 3.6
const TURN_SPEED := 0.45
## How fast it turns (radians a second) and how close to a corner counts as through it.
const TURN_RATE := 1.6
const REACH := 3.0
## Moving slower than this while it wants to drive counts as stuck.
const STUCK_SPEED := 1.0
const WHEELS: Array[Vector3] = [Vector3(-1.1, 0.38, 1.7), Vector3(1.1, 0.38, 1.7), Vector3(-1.1, 0.38, -1.7),
	Vector3(1.1, 0.38, -1.7)]
const MODEL := preload("res://assets/models/ice_cream_truck.glb")
const WHEEL := preload("res://assets/models/car_wheel.glb")

## Where it drives through, in the world (set before it's added, or with follow()).
var points: Array[Vector3] = []
## The next point it heads for; past the last one it stops.
var next := 0
## Seconds it has been stuck in a row, and whether it's driving at all.
var stuck_for := 0.0
var driving := true


func _ready() -> void:
	add_to_group("suspect_car")
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = Vector3(2.2, 2.3, 5.2)
	shape.shape = body
	shape.position.y = 1.35
	add_child(shape)
	add_child(MODEL.instantiate())
	for at in WHEELS:
		var wheel: Node3D = WHEEL.instantiate()
		wheel.position = at
		add_child(wheel)


## Puts it at the start of `route` (in the city's space, which `city` places in the world), facing the way it goes.
func follow(route: ChaseRoute, city: Transform3D) -> void:
	points.clear()
	for point in route.waypoints():
		points.append(city * point)
	next = 1
	global_position = points[0]
	var ahead := points[1] - points[0]
	rotation.y = atan2(ahead.x, ahead.z)


func finished() -> bool:
	return next >= points.size()


func _physics_process(delta: float) -> void:
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	if not driving or finished():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	var to := points[next] - global_position
	to.y = 0.0
	if to.length() < REACH:
		next += 1
		return
	var forward := global_basis.z
	var turn := forward.signed_angle_to(to, Vector3.UP)
	rotation.y += clampf(turn, -TURN_RATE * delta, TURN_RATE * delta)
	# Slows down while its nose isn't on the next point yet: through the corners.
	var speed := SPEED * lerpf(1.0, TURN_SPEED, clampf(absf(turn) / (PI / 2), 0.0, 1.0))
	var wish := global_basis.z * speed
	velocity.x = wish.x
	velocity.z = wish.z
	move_and_slide()
	var moved := Vector2(get_real_velocity().x, get_real_velocity().z).length()
	stuck_for = stuck_for + delta if moved < STUCK_SPEED else 0.0
