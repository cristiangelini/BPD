class_name Lift1987Rig
extends HotelRig

## The lift of 1987 (hotel-allanamiento.md, "El ascensor de 1987"): don Bostezo prints fake money and keeps the case of
## bills in the lift that has been "out of order" since 1987. The cage (OldLift) stands out of the lobby's back wall
## with the case inside, the main evidence; its doors only open with the crank, hidden like the printing plates. The
## story's own clue: the lift's button is worn from so much pressing and has green ink on it. Every number here is
## (propuesta).

const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
const CASE_SCENE := preload("res://scenes/props/fake_money_case.tscn")
## Where the case waits inside the cage (from the cage's foot), and the button beside its doors.
const CASE_IN := Vector3(0, 0.28, 0.75)
const BUTTON_AT := Hotel.LIFT_AT + Vector3(OldLift.SIZE.x / 2 + 0.15, 1.2, OldLift.SIZE.z + 0.03)

var lift: OldLift
var button: ClueNote


func setup(place: HotelRaid) -> void:
	super.setup(place)
	lift = OldLift.new()
	lift.name = "OldLift"
	lift.position = Hotel.LIFT_AT
	place.add_child(lift)
	# The hotel's "out of order" sign goes over the cage's doors.
	var lift_sign: Label3D = place.hotel.get_node("LiftSign")
	lift_sign.position = Hotel.LIFT_AT + Vector3(0, OldLift.SIZE.y - 0.25, OldLift.SIZE.z + 0.05)
	var case: Evidence = CASE_SCENE.instantiate()
	case.position = Hotel.LIFT_AT + CASE_IN
	place.add_child(case)
	place.main = case
	button = NOTE_SCENE.instantiate()
	button.prompt = "PROMPT_LIFT_BUTTON"
	button.text = tr("CLUE_LIFT_BUTTON")
	button.position = BUTTON_AT
	button.rotation.x = PI / 2
	button.freeze = true
	button.read.connect(place.raid.add_clue)
	place.add_child(button)
