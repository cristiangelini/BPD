class_name CityWalker
extends AnimatableBody3D

## Caught with something forbidden after a search (ciudad-viva.md, "Parar y revisar"): cuffed with it, or chased
## down after running off. Pays the shift.
signal busted(walker: CityWalker)

## Someone walking the city's sidewalks (ciudad-viva.md, step 3): round and round their block, with a little bob and
## sway, at their own pace. They're solid (a cop bumps into them) and the handcuffs work on them like on anyone
## (decision 87): cuffed, they stop and complain. The street events stop them and make them talk.
## Every number here is (propuesta).

const MODELS_DIR := "res://assets/models/npc_%s.glb"
const PACE_MIN := 1.0
const PACE_MAX := 1.5
const REACH := 0.4
## Parar y revisar: 1 in CONTRABAND_CHANCE carries something forbidden, and 1 in RUN_CHANCE of those runs when
## stopped. Stopped, they wait HALT seconds. Every number here is (propuesta).
const CONTRABAND_CHANCE := 5
const CONTRABAND_KINDS := 8
const RUN_CHANCE := 3
const HALT := 20.0
const HALT_LINES := 4
const INNOCENT_LINES := 4

@export var look := "cliente"
## Their loop of points on the sidewalk, in walking order.
var path := PackedVector3Array()
var next := 0
var pace := 1.2
## The rain makes them hurry (CityRain).
var hurry := 1.0
var _model: Node3D
var _time := 0.0
var _stopped_left := 0.0
var _cuffed_left := 0.0
var _bubble: Label3D
var _bubble_left := 0.0
## What forbidden thing they carry (0 to CONTRABAND_KINDS - 1), or -1. Drawn when they appear.
var contraband := -1
## Stopped by a cop and waiting to be searched, and searched (what they had is known).
var halted := false
var searched := false
## Running from the police after being stopped (they leave the sidewalk to this runaway).
var runaway: CityRunaway


func _ready() -> void:
	add_to_group("city_walkers")
	sync_to_physics = false
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)
	pace = randf_range(PACE_MIN, PACE_MAX)
	if contraband < 0 and randi() % CONTRABAND_CHANCE == 0:
		contraband = randi() % CONTRABAND_KINDS
	_time = randf() * 10.0
	var scene: PackedScene = load(MODELS_DIR % look)
	_model = scene.instantiate()
	add_child(_model)


## Puts them `along` (0 to 1) their loop, facing the way they walk.
func place_along(along: float) -> void:
	var i := int(fposmod(along, 1.0) * path.size()) % path.size()
	var b := path[(i + 1) % path.size()]
	position = path[i].lerp(b, fposmod(along * path.size(), 1.0))
	next = (i + 1) % path.size()
	var ahead := b - path[i]
	rotation.y = atan2(ahead.x, ahead.z)


## Stops where they are for `seconds` (an event picked them).
func stop_for(seconds: float) -> void:
	_stopped_left = maxf(_stopped_left, seconds)


## Says the line `key` over their head for a few seconds.
func say(key: String, seconds := 4.0) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_STREET_SEARCH" if halted else "PROMPT_STREET_HALT"


## E: the first time "Stop, police!" and they wait; the second time the cop searches their bag.
func use(cop: Cop) -> void:
	if not halted:
		halt(cop)
	else:
		search()


## Stopped by `cop`. Someone carrying something forbidden may run off to the nearest alley instead.
func halt(cop: Cop, run := -1) -> void:
	var runs := run == 1 or (run == -1 and contraband >= 0 and randi() % RUN_CHANCE == 0)
	if runs:
		_run_off()
		return
	halted = true
	stop_for(HALT)
	say("STREET_HALTED_%d" % (randi() % HALT_LINES))
	if cop:
		look_at(Vector3(cop.global_position.x, global_position.y, cop.global_position.z), Vector3.UP, true)


## The bag opens: what they carry, or nothing.
func search() -> void:
	searched = true
	stop_for(HALT)
	say("STREET_FOUND_%d" % contraband if contraband >= 0 else "STREET_NOTHING_%d" % (randi() % INNOCENT_LINES), 6.0)


func _run_off() -> void:
	runaway = CityRunaway.new()
	runaway.route = CityRunaway.route_to(global_position, CityEvents.nearest_alley(global_position))
	get_parent().add_child(runaway)
	runaway.global_position = global_position
	runaway.caught.connect(func() -> void: busted.emit(self))
	# They leave the sidewalk for good: the runaway is them now.
	hide()
	collision_layer = 0
	remove_from_group("city_walkers")
	set_process(false)


## The handcuffs (decision 87): found with something forbidden, they're busted; otherwise they stop and complain,
## they did nothing.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if searched and contraband >= 0:
		say("STREET_BUSTED")
		busted.emit(self)
		contraband = -1
		return
	say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func is_stopped() -> bool:
	return _stopped_left > 0.0 or is_cuffed()


func _process(delta: float) -> void:
	_bubble_left = maxf(_bubble_left - delta, 0.0)
	_bubble.visible = _bubble_left > 0.0
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	_stopped_left = maxf(_stopped_left - delta, 0.0)
	if halted and _stopped_left <= 0.0:
		halted = false
	if path.is_empty() or is_stopped():
		return
	_time += delta
	var to := path[next] - position
	to.y = 0.0
	if to.length() < REACH:
		next = (next + 1) % path.size()
		return
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), minf(1.0, 6.0 * delta))
	position += to.normalized() * pace * hurry * delta
	_model.position.y = absf(sin(_time * pace * 5.0)) * 0.06
	_model.rotation.z = sin(_time * pace * 5.0) * 0.05
