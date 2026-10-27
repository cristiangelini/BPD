class_name TrainRoofChase
extends Node

## The culprit's getaway along the train's roofs (escena-tren.md, "El tablero y el final", pregunta 3): rightly
## accused and running off (CrimeSceneCase.runs_off), the magician climbs out of his window and walks the roofs to the
## front of the locomotive, bowing, slow. The cops climb up the ladder in each car (TrainLadder) and jump the gaps
## between cars. Before each tunnel don Silbato whistles: a cop on a roof who isn't crouching (C) when the tunnel comes
## falls back into the car. Now and then the magician throws a dove at the nearest cop up there (stagger). A cop who
## reaches him catches him; if he reaches the front of the locomotive, he jumps into the river from the bridge and the
## case is lost. Every number here is (propuesta).

signal ended(caught: bool)

## On a roof, in the cars' space: a car's roof is this high over its floor.
const ROOF_Y := GameScale.FLOOR_HEIGHT + 0.1
const SPEED := 0.8
const END_X := 24.0
const CATCH_REACH := 1.1
## The whistle sounds this long before each tunnel.
const WHISTLE_BEFORE := 4.0
const DOVE_EVERY := 5.0
const DOVE_REACH := 8.0
const DOVE_SECONDS := 2.0

var train: Train
var runner: TrainMagician
var done := false
var _dove_left := DOVE_EVERY
var _whistled := -1


## Starts the getaway: the magician up through his window onto his car's roof.
static func begin(on: Train, magician: TrainMagician) -> TrainRoofChase:
	var chase := TrainRoofChase.new()
	chase.name = "RoofChase"
	chase.train = on
	chase.runner = magician
	magician.position = Vector3(magician.position.x, ROOF_Y, 0)
	magician.rotation.y = PI / 2
	magician.collision_layer = 0
	magician.say("MAGICIAN_TA_DA", 2.0)
	on.add_child(chase)
	return chase


func _physics_process(delta: float) -> void:
	if done:
		return
	runner.position.x = minf(runner.position.x + SPEED * delta, END_X)
	_whistle()
	var dark := train.ride.in_tunnel()
	for cop in _cops_on_roof():
		if cop.global_position.distance_to(runner.global_position) <= CATCH_REACH:
			_end(true)
			return
		if dark and not cop.is_crouching:
			fall_in(cop)
	_dove_left -= delta
	if _dove_left <= 0.0:
		_dove_left = DOVE_EVERY
		_throw_dove()
	if runner.position.x >= END_X:
		_end(false)


## The cops standing on a roof.
func _cops_on_roof() -> Array[Cop]:
	var up: Array[Cop] = []
	var roof := train.cars().to_global(Vector3(0, ROOF_Y, 0)).y
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).global_position.y >= roof - 0.3:
			up.append(cop)
	return up


## Don Silbato whistles once before each tunnel, and every cop hears it.
func _whistle() -> void:
	var ride := train.ride
	var to_tunnel := ride.tunnel_start() - ride.leg_time()
	if to_tunnel > 0.0 and to_tunnel <= WHISTLE_BEFORE and _whistled != ride.leg():
		_whistled = ride.leg()
		train.engineer.say("TRAIN_WHISTLE")
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_TRAIN_DUCK")


## Through the skylight, back into the car under him.
func fall_in(cop: Cop) -> void:
	var at := train.cars().to_local(cop.global_position)
	cop.warp(Transform3D(cop.global_basis, train.cars().to_global(Vector3(at.x, 0.1, 0))))
	cop.show_hint("HINT_TRAIN_ROOF_FELL")


func _throw_dove() -> void:
	var nearest: Cop = null
	for cop in _cops_on_roof():
		var gap := cop.global_position.distance_to(runner.global_position)
		if gap <= DOVE_REACH and (not nearest or gap < nearest.global_position.distance_to(runner.global_position)):
			nearest = cop
	if nearest:
		runner.trick()
		nearest.stagger(DOVE_SECONDS)
		nearest.show_hint("HINT_TRAIN_DOVE")


func _end(caught: bool) -> void:
	done = true
	runner.say("TRAIN_MAGICIAN_CAUGHT" if caught else "TRAIN_MAGICIAN_SPLASH", 3.0)
	if not caught:
		runner.hide()
	ended.emit(caught)
