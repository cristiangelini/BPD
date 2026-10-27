class_name FairRides
extends Node

## What makes the fun fair's rides go (allanamiento-parque.md, step 2), each with its control (FairSwitch):
## - the carousel's lever starts it and stops it: it turns at SPIN_RPM, carries whoever stands on it and throws off
##   what's lying loose on its deck;
## - the bumper cars' red button sets the six cars going for BUMPER_SECONDS: they drive on their own round the rink,
##   bounce off the rail and each other, push what they meet and shove a cop they run into;
## - the Ferris wheel's crank turns it by one cabin; the cabins hang straight down all the way round;
## - the ghost train's skeletons jump out at a cop who walks by.
## Every number here is (propuesta).

## A ride was started: "carousel", "bumpers" or "wheel" (Don Tómbola minds it, step 3).
signal ride_started(ride: String)
## The carousel threw something loose off its deck (the first time for each thing).
signal flung(body: RigidBody3D)

const SPIN_RPM := 6.0
## How hard the carousel throws a loose thing outward, in m/s² (on top of the spin).
const FLING := 9.0
const BUMPER_SECONDS := 20.0
const BUMPER_SPEED := 2.4
## Two bumper cars this close bounce off each other; a cop this close gets shoved, at most once a second.
const BUMPER_REACH := 1.7
const BUMPER_SHOVE := 4.0
const SHOVE_EVERY := 1.0
const CRANK_SECONDS := 2.0
const SKELETON_REACH := 1.8
const SKELETON_JUMP := 0.5
const SKELETON_REST := 5.0

## Where each control stands, in the fair's space.
const CAROUSEL_LEVER_AT := Fair.CAROUSEL_AT + Vector3(0, 0, Fair.DECK_RADIUS + 1.0)
const BUMPERS_BUTTON_AT := Fair.RINK_AT + Vector3(-2.2, 0, Fair.RINK_SIZE.y / 2 + 0.8)
const WHEEL_CRANK_AT := Fair.WHEEL_AT + Vector3(2.4, 0, 2.0)

var fair: Fair
var spinning := false
var bumpers_left := 0.0
var turning := false
## Each bumper car's way across the rink, in meters a second (x, z).
var bumper_ways: Array[Vector2] = []
var switches := {}
## Seconds until each skeleton can jump again, and until each cop can be shoved again (by instance id).
var _skeleton_rest: Array[float] = []
var _shoved := {}
var _flung := {}
var _deck_area: Area3D
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = hash(["fair rides", fair.case_seed])
	for ride: String in ["carousel", "bumpers", "wheel"]:
		var switch := FairSwitch.new()
		switch.name = "Switch_" + ride
		switch.ride = ride
		switch.rides = self
		switch.position = {"carousel": CAROUSEL_LEVER_AT, "bumpers": BUMPERS_BUTTON_AT, "wheel": WHEEL_CRANK_AT}[ride]
		switch.pressed.connect(func(_cop: Cop) -> void: press(ride))
		fair.add_child(switch)
		switches[ride] = switch
	for i in fair.bumpers.size():
		bumper_ways.append(Vector2.ZERO)
	_skeleton_rest.resize(fair.skeletons.size())
	_skeleton_rest.fill(0.0)
	_deck_area = Area3D.new()
	_deck_area.name = "DeckArea"
	_deck_area.collision_layer = 0
	_deck_area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = Fair.DECK_RADIUS
	cylinder.height = 1.6
	shape.shape = cylinder
	shape.position.y = Fair.DECK_TOP + 0.8
	_deck_area.add_child(shape)
	_deck_area.position = Fair.CAROUSEL_AT
	fair.add_child(_deck_area)


## What E on a ride's control says.
func prompt_for(ride: String) -> String:
	match ride:
		"carousel":
			return "PROMPT_FAIR_CAROUSEL_OFF" if spinning else "PROMPT_FAIR_CAROUSEL_ON"
		"bumpers":
			return "PROMPT_FAIR_BUMPERS_RUNNING" if bumpers_left > 0.0 else "PROMPT_FAIR_BUMPERS"
	return "PROMPT_FAIR_CRANK"


## A ride's control was used.
func press(ride: String) -> void:
	match ride:
		"carousel":
			spinning = not spinning
			if spinning:
				ride_started.emit(ride)
		"bumpers":
			if bumpers_left > 0.0:
				return
			bumpers_left = BUMPER_SECONDS
			for i in bumper_ways.size():
				bumper_ways[i] = Vector2.from_angle(_rng.randf() * TAU) * BUMPER_SPEED
			ride_started.emit(ride)
		"wheel":
			crank()


## The wheel turns by one cabin, unless it's still turning.
func crank() -> void:
	if turning:
		return
	turning = true
	ride_started.emit("wheel")
	var tween := fair.create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(fair.wheel, "rotation:z", fair.wheel.rotation.z - TAU / Fair.CABINS, CRANK_SECONDS) \
		.set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func() -> void: turning = false)


## The cabin at the top of the wheel now.
func top_cabin() -> Node3D:
	var top: Node3D = fair.cabins[0]
	for cabin in fair.cabins:
		if cabin.global_position.y > top.global_position.y:
			top = cabin
	return top


func _physics_process(delta: float) -> void:
	for cabin in fair.cabins:
		cabin.rotation.z = -fair.wheel.rotation.z
	if spinning:
		fair.carousel.rotation.y += TAU * SPIN_RPM / 60.0 * delta
		for body in _deck_area.get_overlapping_bodies():
			if body is RigidBody3D and not (body as RigidBody3D).freeze:
				var out := (body as Node3D).global_position - _deck_area.global_position
				out.y = 0.0
				(body as RigidBody3D).sleeping = false
				(body as RigidBody3D).apply_central_force(out.normalized() * FLING * (body as RigidBody3D).mass)
				if not _flung.has(body.get_instance_id()):
					_flung[body.get_instance_id()] = true
					flung.emit(body)
	if bumpers_left > 0.0:
		bumpers_left -= delta
		_drive_bumpers(delta)
	for key: int in _shoved.keys():
		_shoved[key] -= delta
		if _shoved[key] <= 0.0:
			_shoved.erase(key)
	_scare(delta)


## Each car goes its way, bouncing off the rail and off the others, and shoves a cop it runs into.
func _drive_bumpers(delta: float) -> void:
	var half := Fair.RINK_SIZE / 2 - Vector2(Fair.BUMPER_SIZE.z, Fair.BUMPER_SIZE.z) / 2
	for i in fair.bumpers.size():
		var car := fair.bumpers[i]
		var way := bumper_ways[i]
		var at := Vector2(car.position.x - Fair.RINK_AT.x, car.position.z - Fair.RINK_AT.z) + way * delta
		if absf(at.x) > half.x:
			way.x = -signf(at.x) * absf(way.x)
		if absf(at.y) > half.y:
			way.y = -signf(at.y) * absf(way.y)
		for j in fair.bumpers.size():
			var other := fair.bumpers[j]
			var gap := Vector2(car.position.x - other.position.x, car.position.z - other.position.z)
			if j != i and gap.length() < BUMPER_REACH and way.dot(gap) < 0.0:
				way = way.bounce(gap.normalized())
		at = at.clamp(-half, half)
		bumper_ways[i] = way
		car.position = Vector3(Fair.RINK_AT.x + at.x, car.position.y, Fair.RINK_AT.z + at.y)
		car.rotation.y = atan2(way.x, way.y)
		for cop in fair.get_tree().get_nodes_in_group("cops"):
			var off := (cop as Node3D).global_position - car.global_position
			off.y = 0.0
			if off.length() < BUMPER_REACH * 0.7 and not _shoved.has(cop.get_instance_id()):
				_shoved[cop.get_instance_id()] = SHOVE_EVERY
				(cop as Cop).knock_back(off.normalized() * BUMPER_SHOVE, 0.4)


## A skeleton jumps out at a cop who comes close, then rests a while.
func _scare(delta: float) -> void:
	for i in fair.skeletons.size():
		_skeleton_rest[i] = maxf(_skeleton_rest[i] - delta, 0.0)
		if _skeleton_rest[i] > 0.0:
			continue
		var skeleton := fair.skeletons[i]
		for cop in fair.get_tree().get_nodes_in_group("cops"):
			if (cop as Node3D).global_position.distance_to(skeleton.global_position) < SKELETON_REACH:
				jump(i)
				break


func jump(index: int) -> void:
	_skeleton_rest[index] = SKELETON_REST
	var skeleton := fair.skeletons[index]
	var rest := skeleton.position.y
	var tween := fair.create_tween()
	tween.tween_property(skeleton, "position:y", rest + SKELETON_JUMP, 0.12)
	tween.tween_property(skeleton, "position:y", rest, 0.5).set_trans(Tween.TRANS_BOUNCE)
	fair.say(skeleton.position + Vector3(0, 2.4, 0), "FAIR_SKELETON_BOO")
