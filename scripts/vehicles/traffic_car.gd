class_name TrafficCar
extends CharacterBody3D

## A slow car of the highway's traffic (persecucion-lugares.md, "En la autopista"): it drives the ring at 50 km/h in
## one of the two lanes of its way, forever, and moves over to the other lane when the suspect comes up behind it, so
## the chase is about the patrol car dodging it. It has the toll tag: the barriers lift for it. Hitting it is a crash
## (ChaseDamages). Forward is +Z, like the other vehicles. Every number here is (propuesta).

const SPEED := 50.0 / 3.6
const TURN_RATE := 1.6
const REACH := 4.0
## It steers for its lane this far ahead, so moving over is quick even on a long side.
const LOOK_AHEAD := 20.0
## The suspect this close behind, in its lane, makes it move over.
const YIELD_BEHIND := 35.0
const YIELD_SIDE := 2.0
## Seconds it stays in the new lane before it can move over again.
const LANE_SECONDS := 4.0
const MODELS: Array[PackedScene] = [preload("res://assets/models/traffic_car_0.glb"),
	preload("res://assets/models/traffic_car_1.glb"), preload("res://assets/models/traffic_car_2.glb"),
	preload("res://assets/models/traffic_car_3.glb")]
const WHEEL := preload("res://assets/models/car_wheel.glb")

## Its way's two lanes (closed loops of points, in the world, in driving order), the one it's in and its next point.
var lanes: Array[PackedVector3Array] = []
var lane := 0
var next := 0
var look := 0
## Who it moves over for.
var suspect: Node3D
var _in_lane_for := LANE_SECONDS


func _ready() -> void:
	add_to_group("traffic")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.1, 1.4, 4.6)
	shape.shape = box
	shape.position.y = box.size.y / 2 + 0.2
	add_child(shape)
	add_child(MODELS[look % MODELS.size()].instantiate())
	for at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = WHEEL.instantiate()
		wheel.position = at
		add_child(wheel)


## Puts it `along` (0 to 1) the piece from point `index` of `lane_number`, facing the next point.
func place(lane_number: int, index: int, along := 0.0) -> void:
	lane = lane_number
	var loop := lanes[lane]
	next = (index + 1) % loop.size()
	global_position = loop[index].lerp(loop[next], along) + Vector3.UP * 0.2
	var ahead := loop[next] - loop[index]
	rotation.y = atan2(ahead.x, ahead.z)


func _physics_process(delta: float) -> void:
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	if lanes.is_empty():
		return
	_in_lane_for += delta
	if _in_lane_for >= LANE_SECONDS and _suspect_behind():
		lane = 1 - lane
		_in_lane_for = 0.0
	var loop := lanes[lane]
	var to := loop[next] - global_position
	to.y = 0.0
	if to.length() < REACH:
		next = (next + 1) % loop.size()
		return
	var from := loop[(next - 1 + loop.size()) % loop.size()]
	var along := (loop[next] - from).normalized()
	var ahead := (global_position - from).dot(along) + LOOK_AHEAD
	if ahead < from.distance_to(loop[next]):
		to = from + along * ahead - global_position
		to.y = 0.0
	var turn := global_basis.z.signed_angle_to(to, Vector3.UP)
	rotation.y += clampf(turn, -TURN_RATE * delta, TURN_RATE * delta)
	var wish := global_basis.z * SPEED
	velocity.x = wish.x
	velocity.z = wish.z
	move_and_slide()


## The suspect is coming up right behind it, in its lane.
func _suspect_behind() -> bool:
	if not is_instance_valid(suspect):
		return false
	var offset := global_transform.affine_inverse() * suspect.global_position
	return offset.z < 0.0 and offset.z > -YIELD_BEHIND and absf(offset.x) < YIELD_SIDE
