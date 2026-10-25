class_name CityCar
extends AnimatableBody3D

## A car of the city's traffic (ciudad-viva.md, step 3): it drives a closed loop of streets in its right-hand lane,
## forever, and stops behind whatever is in front of it (another car, a crossing car, a cop, someone walking) until
## the way is clear. It follows its path, not physics, but it's solid: the patrol car and the cops bump into it.
## Forward is +Z, like the other vehicles. Every number here is (propuesta).

const SPEED := 30.0 / 3.6
const TURN_RATE := 2.5
const REACH := 2.0
## Something this close ahead, this far to the side, makes it stop.
const STOP_AHEAD := 8.0
const STOP_SIDE := 1.6
## Stopped this long, it goes anyway, so two cars at a crossing never wait for each other forever.
const PATIENCE := 3.0
## How often (s) it looks ahead, so a city full of cars and people stays cheap.
const LOOK_EVERY := 0.1

## Its loop of points on the ground, in driving order.
var path := PackedVector3Array()
var look := 0
var next := 0
var stopped_for := 0.0
var _blocked := false
var _look_left := 0.0


func _ready() -> void:
	add_to_group("city_cars")
	sync_to_physics = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.1, 1.4, 4.6)
	shape.shape = box
	shape.position.y = box.size.y / 2 + 0.2
	add_child(shape)
	add_child(TrafficCar.MODELS[look % TrafficCar.MODELS.size()].instantiate())
	for at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = at
		add_child(wheel)


## Puts it `along` (0 to 1) its whole loop, facing the way it drives.
func place_along(along: float) -> void:
	var total := 0.0
	for i in path.size():
		total += path[i].distance_to(path[(i + 1) % path.size()])
	var left := fposmod(along, 1.0) * total
	for i in path.size():
		var b := path[(i + 1) % path.size()]
		var piece := path[i].distance_to(b)
		if left <= piece:
			position = path[i].move_toward(b, left)
			next = (i + 1) % path.size()
			var ahead := b - path[i]
			rotation.y = atan2(ahead.x, ahead.z)
			return
		left -= piece


func _physics_process(delta: float) -> void:
	if path.is_empty():
		return
	var to := path[next] - position
	to.y = 0.0
	if to.length() < REACH:
		next = (next + 1) % path.size()
		return
	var turn := basis.z.signed_angle_to(to, Vector3.UP)
	rotation.y += clampf(turn, -TURN_RATE * delta, TURN_RATE * delta)
	_look_left -= delta
	if _look_left <= 0.0:
		_look_left = LOOK_EVERY
		_blocked = blocked()
	if _blocked:
		stopped_for += delta
		if stopped_for < PATIENCE:
			return
	else:
		stopped_for = 0.0
	position += basis.z * SPEED * delta


## Something is right in front of it: a car of the city or a cop's car, or someone walking.
func blocked() -> bool:
	for group: String in ["city_cars", "city_walkers", "cops", "patrol_cars"]:
		for other: Node in get_tree().get_nodes_in_group(group):
			if other == self or not other is Node3D:
				continue
			var offset := global_transform.affine_inverse() * (other as Node3D).global_position
			if offset.z > 0.5 and offset.z < STOP_AHEAD and absf(offset.x) < STOP_SIDE:
				return true
	return false
