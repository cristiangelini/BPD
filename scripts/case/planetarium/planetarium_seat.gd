class_name PlanetariumSeat
extends StaticBody3D

## A plain reclining seat of the dome room (escena-planetario.md, "La función de las estrellas"): during the show, E and
## the cop sits back to watch the sky. Doctor Órbita is delighted (StarShow.seated: +patience), but the seat is so
## comfortable that the cop can't get up for SIT_SECONDS. With the lights on there's nothing to watch. Every number
## here is (propuesta).

const SIT_SECONDS := 10.0
## The seat's cushion, over its feet.
const SIZE := Vector3(0.7, 0.5, 0.7)

var planetarium: Planetarium
var sitter: Cop
var _left := 0.0


func _init() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)


func prompt_key(cop: Cop) -> String:
	if sitter == cop:
		return "PROMPT_SEAT_STUCK"
	return "" if sitter else "PROMPT_SEAT_SIT"


## E: during the show the cop sits down and watches; with the lights on, nothing happens.
func use(cop: Cop) -> void:
	if sitter or not cop:
		return
	var show := planetarium.star_show if planetarium else null
	if not show or not show.is_on():
		cop.show_hint("HINT_SEAT_NO_SHOW")
		return
	cop.get_node("Grabber").release()
	cop.seated_in = self
	sitter = cop
	_left = SIT_SECONDS
	cop.velocity = Vector3.ZERO
	cop.global_position = global_position + Vector3.UP * (SIZE.y / 2)
	show.seated(cop)


## E again while sitting: too comfortable to get up until the time is over.
func stand_up() -> void:
	if sitter and _left > 0.0:
		sitter.show_hint("HINT_SEAT_STUCK")


func _physics_process(delta: float) -> void:
	if not sitter:
		return
	_left -= delta
	if _left <= 0.0:
		sitter.seated_in = null
		sitter = null
