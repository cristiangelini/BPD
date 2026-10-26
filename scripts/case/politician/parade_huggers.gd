class_name ParadeHuggers
extends Node

## The fans who climb on the convertible to hug deputy Lustre (politico-descapotable.md, step 2, decision 222): while
## the parade goes on, every HUG_EVERY seconds the nearest fan on the sidewalks (not a heckler, nor the cuffed) runs to
## the car and climbs on behind him. Up there, each STAIN_EVERY seconds the hug creases his suit, a stain on his image.
## E on the hugger (RallyFan.hugging) pulls them off, and they walk back to their spot on the sidewalk. One at a time.
## When the parade ends, whoever is up gets off. It runs on the host. Every number here is (propuesta).

enum State { WAITING, RUNNING, HUGGING, GOING_BACK }

const HUG_EVERY := 50.0
const FIRST_HUG := 30.0
## Only a fan this close to the car runs to it.
const REACH := 25.0
const RUN_SPEED := 3.2
const WALK_SPEED := 1.4
## Close enough to the car's side to climb on (from its body's edge).
const CLIMB := 0.7
const ARRIVED := 0.4
const STAIN_EVERY := 5.0
## A run to the car or back that takes longer than this (stuck on a curb) ends there: they give up, or are home.
const LEG_TIME := 20.0
const HUG_LINES := 3
## Where the hugger stands on the car, behind the deputy, in the car's own space.
const ON_CAR := Vector3(0, 0.55, -1.7)

var car: ParadeCar
var politician: Politician
var speech: PoliticianSpeech
var crowd: RallyCrowd
var state := State.WAITING
## The fan running to the car, hugging him or going back.
var hugger: RallyFan
## How many climbed on so far, and how many the cops pulled off.
var hugs := 0
var pulled := 0
var _wait_left := FIRST_HUG
var _stain_left := 0.0
var _home := Vector3.ZERO
var _home_turn := 0.0
var _leg_left := 0.0


func setup(the_car: ParadeCar, rider: Politician, the_speech: PoliticianSpeech, the_crowd: RallyCrowd,
		_case_seed: int) -> void:
	car = the_car
	politician = rider
	speech = the_speech
	crowd = the_crowd
	for fan in crowd.fans:
		fan.pulled_off.connect(_on_pulled_off)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if speech.over and (state == State.RUNNING or state == State.HUGGING):
		_back()
	match state:
		State.WAITING:
			if not speech.speaking or speech.over:
				return
			_wait_left -= delta
			if _wait_left <= 0.0:
				var fan := nearest_fan()
				if fan:
					_run(fan)
		State.RUNNING:
			_leg_left -= delta
			if not hugger.free_to_throw() or _leg_left <= 0.0:
				_back()
			elif at_car(hugger) or _move_to(car.global_position, RUN_SPEED, delta, 0.0):
				_climb()
		State.HUGGING:
			hugger.global_position = car.global_transform * ON_CAR
			hugger.rotation.y = car.rotation.y + PI
			_stain_left -= delta
			if _stain_left <= 0.0:
				_stain_left = STAIN_EVERY
				politician.stain(Politician.SHAME, politician.global_position + Vector3.UP)
				hugger.say("PARADE_HUG_%d" % (hugs % HUG_LINES + 1))
		State.GOING_BACK:
			_leg_left -= delta
			if _leg_left <= 0.0:
				hugger.global_position = _home
			if _leg_left <= 0.0 or _move_to(_home, WALK_SPEED, delta, ARRIVED):
				hugger.velocity = Vector3.ZERO
				hugger.rotation.y = _home_turn
				hugger = null
				state = State.WAITING
				_wait_left = HUG_EVERY


## The fan nearest to the car, within REACH, who'd run to it: not a heckler, nor cuffed or taken away.
func nearest_fan() -> RallyFan:
	var best: RallyFan
	var best_away := REACH
	for fan in crowd.fans:
		if fan.heckler or not fan.free_to_throw():
			continue
		var away := fan.global_position.distance_to(car.global_position)
		if away < best_away:
			best_away = away
			best = fan
	return best


## `fan` is within CLIMB of the car's body.
func at_car(fan: Node3D) -> bool:
	var local := car.global_transform.affine_inverse() * fan.global_position
	var out := Vector2(maxf(absf(local.x) - ParadeCar.SIZE.x / 2, 0.0), maxf(absf(local.z) - ParadeCar.SIZE.z / 2, 0.0))
	return out.length() < CLIMB


func _run(fan: RallyFan) -> void:
	hugger = fan
	state = State.RUNNING
	_home = fan.global_position
	_home_turn = fan.rotation.y
	_leg_left = LEG_TIME
	fan.say("PARADE_HUG_RUN")


func _climb() -> void:
	state = State.HUGGING
	hugs += 1
	hugger.hugging = true
	hugger.collision_layer = 0
	_stain_left = STAIN_EVERY
	hugger.say("PARADE_HUG_ON")
	politician.say("PARADE_HUGGED")


func _on_pulled_off(fan: RallyFan, cop: Cop) -> void:
	if fan != hugger or state != State.HUGGING:
		return
	cop.stats["huggers_off"] = cop.stats.get("huggers_off", 0) + 1
	pulled += 1
	fan.say("PARADE_HUG_OFF")
	# Down beside the car, on the side of the cop who pulled them off.
	var side := (cop.global_position - car.global_position)
	side.y = 0.0
	fan.global_position = car.global_position + side.normalized() * (ParadeCar.SIZE.x / 2 + CLIMB) + Vector3.UP * 0.1
	_back()


func _back() -> void:
	hugger.hugging = false
	hugger.collision_layer = 8
	_leg_left = LEG_TIME
	state = State.GOING_BACK


## Walks the hugger toward `to` on the ground; true once within `close`.
func _move_to(to: Vector3, speed: float, delta: float, close: float) -> bool:
	var way := to - hugger.global_position
	way.y = 0.0
	if way.length() < close:
		hugger.velocity = Vector3.ZERO
		return true
	var wish := way.normalized() * speed
	hugger.rotation.y = atan2(-wish.x, -wish.z)
	hugger.velocity.x = wish.x
	hugger.velocity.z = wish.z
	hugger.velocity.y = 0.0 if hugger.is_on_floor() else hugger.velocity.y - GameScale.GRAVITY * delta
	hugger.move_and_slide()
	return false
