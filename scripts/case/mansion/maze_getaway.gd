class_name MazeGetaway
extends Node

## The accused culprit runs off on foot through the hedge maze (escena-mansion.md, "El tablero y el final", step 6):
## out of the house by the garden door, into the maze and through it the wrong way and the right way
## (Mansion.getaway_route) to the gate at the far end. A cop who gets within CATCH_REACH of him tackles him: caught.
## Out the gate, or ESCAPE_SECONDS gone, he got away. Every number here is (propuesta).

signal ended(caught: bool)

## Meters a second: a cop running catches up, one walking doesn't.
const RUN_SPEED := 2.6
const ESCAPE_SECONDS := 90.0
const CATCH_REACH := 1.1

var mansion: Mansion
var runner: MysteryMember
## His way, in the mansion's space, and the next point of it.
var route: Array[Vector3] = []
var next := 0
var time_left := ESCAPE_SECONDS
var caught := false
var escaped := false
var over := false


## He drops what he was doing and bolts.
func start(member: MysteryMember) -> void:
	runner = member
	if runner.walk:
		runner.walk.kill()
		runner.walk = null
	var room := runner.room if runner.room != "" else str(runner.traits.room)
	route = mansion.getaway_route(room)
	runner.room = ""


func _physics_process(delta: float) -> void:
	if over or not runner:
		return
	time_left -= delta
	for cop in get_tree().get_nodes_in_group("cops"):
		var off := (cop as Node3D).global_position - runner.global_position
		if Vector2(off.x, off.z).length() <= CATCH_REACH:
			catch()
			return
	var step := RUN_SPEED * delta
	while step > 0.0 and next < route.size():
		var to := route[next] - runner.position
		to.y = 0.0
		if to.length() <= step:
			runner.position = Vector3(route[next].x, runner.position.y, route[next].z)
			step -= to.length()
			next += 1
		else:
			runner.position += to.normalized() * step
			runner.rotation.y = atan2(to.x, to.z)
			step = 0.0
	if next >= route.size() or time_left <= 0.0:
		get_away()


func catch() -> void:
	if over:
		return
	over = true
	caught = true
	runner.say("MEMBER_CAUGHT")
	_hint_all("HINT_MAZE_CAUGHT")
	ended.emit(true)


func get_away() -> void:
	if over:
		return
	over = true
	escaped = true
	runner.hide()
	runner.collision_layer = 0
	_hint_all("HINT_MAZE_ESCAPED")
	ended.emit(false)


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
