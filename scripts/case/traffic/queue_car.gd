class_name QueueCar
extends CharacterBody3D

## A car that comes to the traffic control (control-transito.md, "Cómo es el caso", step 3): it drives down the lane
## toward the checkpoint, stops at the barrier or behind the car ahead and waits there until the cops let it through
## (TrafficQueue.release_front), or until the queue runs out of patience and it sneaks by along the sidewalk, knocking
## the cones over. It moves in the checkpoint's space, along local -Z, without physics: cars don't push the cops'
## things, they just stop. Every number here is (propuesta).

const SPEED := 30.0 / 3.6
## Brakes and speeds up this hard, in m/s².
const ACCEL := 6.0
const LENGTH := 4.6
## Space left to the car ahead when stopped, in meters.
const GAP := 1.5
## Where its middle stops before the checkpoint's box edge.
const STOP_BEFORE := LENGTH / 2 + 0.5
## Sneaking, it moves over this far toward the sidewalk (the checkpoint's +X).
const SNEAK_SIDE := 4.5
## Cones this close to it when sneaking get knocked over, with this kick (m/s).
const KNOCK_REACH := 1.6
const KNOCK_SPEED := 4.0
## Gone this far past the checkpoint.
const GONE_AT := -60.0

## "coming", "waiting", "going" (let through), "sneaking" or "gone".
var state := "coming"
var checkpoint: TrafficCheckpoint
## The car right in front in the queue, if any.
var ahead: QueueCar
var look := 0
var speed := 0.0
## Its place in the checkpoint's space: x across the lane, z along it.
var at := Vector3.ZERO


func _ready() -> void:
	add_to_group("queue_cars")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.1, 1.4, LENGTH)
	shape.shape = box
	shape.position.y = box.size.y / 2 + 0.2
	add_child(shape)
	add_child(TrafficCar.MODELS[look % TrafficCar.MODELS.size()].instantiate())
	for wheel_at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = wheel_at
		add_child(wheel)
	_place()


func waiting() -> bool:
	return state == "waiting"


## In the queue, stopped or rolling up to it: not let through, not sneaking, not gone.
func in_queue() -> bool:
	return state == "coming" or state == "waiting"


func let_through() -> void:
	if in_queue():
		state = "going"


func sneak() -> void:
	if in_queue():
		state = "sneaking"


## Where it wants to stop, in the checkpoint's z; INF for no stop.
func _stop_z() -> float:
	if not in_queue():
		return -INF
	var stop := TrafficCheckpoint.ZONE.y / 2 + STOP_BEFORE if checkpoint.barrier_ok() else -INF
	if is_instance_valid(ahead) and ahead.in_queue():
		stop = maxf(stop, ahead.at.z + LENGTH + GAP)
	return stop


func _physics_process(delta: float) -> void:
	if state == "gone" or not checkpoint:
		return
	var stop := _stop_z()
	var room := at.z - stop
	# Slows down to stop right at `stop`: v² = 2·a·d.
	var top := SPEED if room == INF else minf(SPEED, sqrt(maxf(2.0 * ACCEL * room, 0.0)))
	speed = move_toward(speed, top, ACCEL * delta)
	if room <= 0.05:
		speed = 0.0
	# Never past where it stops, even with a long tick.
	at.z = maxf(at.z - speed * delta, stop)
	if state == "sneaking":
		at.x = move_toward(at.x, SNEAK_SIDE, 2.5 * delta)
	if state == "coming" and speed == 0.0:
		state = "waiting"
	elif state == "waiting" and speed > 0.0:
		state = "coming"
	if at.z < GONE_AT:
		state = "gone"
		queue_free()
		return
	_place()
	if state == "sneaking":
		_knock_cones()


func _place() -> void:
	if checkpoint:
		global_transform = checkpoint.global_transform * Transform3D(Basis(Vector3.UP, PI), at + Vector3.UP * 0.05)


func _knock_cones() -> void:
	for cone: TrafficCone in get_tree().get_nodes_in_group("traffic_cones"):
		var off := cone.global_position - global_position
		off.y = 0
		if off.length() < KNOCK_REACH and cone.standing():
			cone.linear_velocity = (off.normalized() + Vector3.UP * 0.6) * KNOCK_SPEED
			cone.angular_velocity = Vector3(randf_range(-6, 6), 0, randf_range(-6, 6))
