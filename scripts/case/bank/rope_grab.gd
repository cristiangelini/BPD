class_name RopeGrab
extends Node3D

## El Oso's rope under the toy helicopter (robo-banco-techo.md, step 4b, decision 126): it rides on the fleeing
## helicopter at his hands. A cop riding beside the driver of a patrol car right under it reaches out of the window
## and grabs it with E (Cop.window_target): `grabbed` goes off and the level drops El Oso cuffed into the back seat.
## Every number here is (propuesta).

signal grabbed(cop: Cop)

## How close (seen from above) the patrol car has to pass under him.
const REACH := 2.5

## Off once he's caught.
var active := true


func _ready() -> void:
	add_to_group("window_reach")


## Whether `cop` can grab it from the patrol car now: riding, but not driving, right under him.
func can_reach(cop: Cop) -> bool:
	if not active or not cop.vehicle or cop.vehicle.seat_of(cop) == 0:
		return false
	# Online a guest's copy knows he's caught when the host's rope goes (SuspectCar.get_off).
	var rope := get_parent().get_node_or_null("Rope") as Node3D
	if rope and not rope.visible:
		return false
	var gap := cop.vehicle.global_position - global_position
	return Vector2(gap.x, gap.z).length() <= REACH


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GRAB_ROPE"


func use(cop: Cop) -> void:
	if not active:
		return
	active = false
	grabbed.emit(cop)
