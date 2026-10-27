class_name VcrDeck
extends StaticBody3D

## The VCR on the evidence room's table that the ceiling camera records on (escena-comisaria.md, "Las pistas"). If the
## tape is one of the case's clues, E rewinds it and the monitor shows last night: a silhouette in a cap, from behind,
## tall or short and limping or not. It never stops recording, though: after OVERWRITE seconds of the case the tape
## loops over last night and the clue is lost. Every number here is (propuesta).

## Around the whole table, so a cop aiming at it gets the VCR.
const SIZE := Vector3(0.84, 0.95, 0.54)
const OVERWRITE := 300.0

var case: CrimeSceneCase
var has_tape := false
var watched := false
var overwritten := false
var _recording := 0.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_VCR"


## E: rewind and watch.
func use(cop: Cop) -> void:
	if not has_tape or overwritten:
		cop.show_hint("HINT_VCR_BLANK" if not overwritten else "HINT_VCR_OVERWRITTEN")
		return
	watched = true
	case.found("tape")
	cop.show_hint(case.clue_line("tape"))


func _physics_process(delta: float) -> void:
	if not has_tape or watched or overwritten or not case or not case.tip_given:
		return
	_recording += delta
	if _recording >= OVERWRITE:
		overwritten = true
		case.ruin("tape")
