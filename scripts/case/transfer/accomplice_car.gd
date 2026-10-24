class_name AccompliceCar
extends Node3D

## The accomplice's car (traslado-presos.md, step 3c, decision 105): a dark sedan that turns up behind the bus and
## follows it along the road it drove, FOLLOW metres back. When the bus stands still for HAND_STOP seconds it pulls up
## by `inmate`'s window and hands them a file through the bars (`handed`); then it drives off (and is gone LEAVE_SECONDS later). If the bus doesn't stop
## within GIVE_UP seconds, it gives up and drives off too. Just looks: it doesn't collide. Every number here is
## (propuesta).

signal handed(inmate: BusInmate)

const MODEL := preload("res://assets/models/getaway_car.glb")
const WHEEL := preload("res://assets/models/car_wheel.glb")
const WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 1.55), Vector3(1.05, 0.38, 1.55), Vector3(-1.05, 0.38, -1.55),
	Vector3(1.05, 0.38, -1.55)]
const FOLLOW := 14.0
const SPEED := 16.0
const HAND_STOP := 1.5
const GIVE_UP := 60.0
## Alongside, its middle this far from the bus's side.
const ALONGSIDE := 1.6
const LEAVE_SECONDS := 2.5
## The bus counts as stopped below this speed (m/s), and the trail keeps a point every this many metres.
const STOPPED := 1.0
const TRAIL_STEP := 1.0

var bus: PrisonBus
var inmate: BusInmate
var gave_up := false
var leaving := false
var _trail: Array[Vector3] = []
var _stopped := 0.0
var _left := GIVE_UP
var _leave_left := LEAVE_SECONDS


func _ready() -> void:
	add_child(MODEL.instantiate())
	for at in WHEELS:
		var wheel: Node3D = WHEEL.instantiate()
		wheel.position = at
		add_child(wheel)
	# A guest's copy (NpcSync) only follows the host's.
	if not bus:
		return
	var behind := bus.global_position - bus.global_basis.z * FOLLOW
	global_transform = Transform3D(Basis(Vector3.UP, bus.global_basis.get_euler().y), Vector3(behind.x, 0.0, behind.z))
	_trail.append(global_position)


func _physics_process(delta: float) -> void:
	if leaving:
		_drive_to(global_position + global_basis.z * SPEED, delta)
		_leave_left -= delta
		if _leave_left <= 0.0:
			queue_free()
		return
	var ground := Vector3(bus.global_position.x, global_position.y, bus.global_position.z)
	if _trail.is_empty() or _trail.back().distance_to(ground) > TRAIL_STEP:
		_trail.append(ground)
	_left -= delta
	_stopped = _stopped + delta if absf(bus.forward_speed()) < STOPPED else 0.0
	if not is_instance_valid(inmate) or not inmate.seated or _left <= 0.0:
		gave_up = true
		leaving = true
		return
	if _stopped >= HAND_STOP:
		var side := signf(PrisonBus.seat_spot(inmate.seat).x)
		var window := bus.to_global(Vector3(side * (PrisonBus.HALF_WIDTH + ALONGSIDE), 0.0, PrisonBus.seat_spot(inmate.seat).z))
		window.y = global_position.y
		_drive_to(window, delta)
		if global_position.distance_to(window) < 0.3:
			leaving = true
			handed.emit(inmate)
		return
	# Along the bus's own road, FOLLOW metres behind it.
	if global_position.distance_to(ground) > FOLLOW:
		while _trail.size() > 1 and global_position.distance_to(_trail[0]) < 0.5:
			_trail.pop_front()
		_drive_to(_trail[0], delta)


## Moves toward `to` at SPEED, facing where it goes (its front is +Z).
func _drive_to(to: Vector3, delta: float) -> void:
	var step := to - global_position
	step.y = 0.0
	if step.length() < 0.01:
		return
	global_position = global_position.move_toward(Vector3(to.x, global_position.y, to.z), SPEED * delta)
	if step.length() > 0.2:
		global_basis = Basis(Vector3.UP, atan2(step.x, step.z))
