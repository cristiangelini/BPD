class_name ChaseDamages
extends Node

## The damage the patrol car does to the city in a chase (persecucion.md, "Cómo es el caso"): every hard crash into
## something of the city (a wall, a traffic light, a tree) is a fine, taken off the pay like the raid's broken
## ornaments. Ramming the suspect's vehicle is the job, so it's free. Every number here is (propuesta).

## Touching something of the city and losing this much speed at once (m/s, 15 km/h) is a crash, and each one costs
## FINE. Driving onto the sidewalk or scraping a wall loses far less.
const CRASH_DROP := 15.0 / 3.6
const FINE := 50
## The same thing hit again this soon (the car scraping along a wall) is the same crash.
const COOLDOWN := 1.0
## The speed lost is measured over this many frames, from a little before the touch.
const SPEED_FRAMES := 8

signal crashed(fines: int)

var car: PatrolCar
var crashes := 0
var fines := 0
var _speeds: Array[float] = []
var _last_hit := {}
## What the car touched, waiting to see whether it slowed down enough to be a crash, and frames left to see it.
var _touched: StaticBody3D
var _watch := 0


func _ready() -> void:
	car.contact_monitor = true
	car.max_contacts_reported = 8


func _physics_process(_delta: float) -> void:
	_speeds.append(car.linear_velocity.length())
	if _speeds.size() > SPEED_FRAMES:
		_speeds.pop_front()
	_look_at_contacts()
	if _watch <= 0:
		return
	_watch -= 1
	if speed_lost() >= CRASH_DROP and is_instance_valid(_touched):
		_crash(_touched)
		_watch = 0


## The most speed lost over the last frames.
func speed_lost() -> float:
	var fastest := 0.0
	for speed in _speeds:
		fastest = maxf(fastest, speed)
	return fastest - car.linear_velocity.length()


## Something of the city touched from the side (not the ground under the car). Only the city's own things count:
## not the suspect, the cops or anyone walking.
func _look_at_contacts() -> void:
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	if not state:
		return
	for i in state.get_contact_count():
		var body := state.get_contact_collider_object(i) as StaticBody3D
		if body and absf(state.get_contact_local_normal(i).y) < 0.5:
			if body != _touched or _watch <= 0:
				_touched = body
				_watch = SPEED_FRAMES


func _crash(body: StaticBody3D) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - float(_last_hit.get(body.get_instance_id(), -INF)) < COOLDOWN:
		return
	_last_hit[body.get_instance_id()] = now
	crashes += 1
	fines += FINE
	crashed.emit(fines)
