class_name TrainShowcase
extends StaticBody3D

## The empty glass showcase in the luggage car where the stolen thing travelled (escena-tren.md, "Las pistas"). The
## culprit took a glove off to open it: if the prints are one of the case's clues, the print kit (PrintKit, `dusted`)
## finds them on the glass; a cop who touches it first (E) leaves his own on top, like the museum's empty frame.

const SIZE := Vector3(0.7, 0.6, 0.5)

var case: CrimeSceneCase
var has_prints := false
## A cop touched it.
var touched := false


func _init() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRAIN_SHOWCASE"


## E: the cop puts a hand on the glass and leaves his prints on it.
func use(cop: Cop) -> void:
	var spoils := has_prints and not touched and case and not case.clues_found.has("prints")
	touched = true
	if spoils:
		case.ruin("prints")
	cop.show_hint("HINT_SHOWCASE_TOUCHED" if spoils else "HINT_SHOWCASE_EMPTY")


## The print kit dusted it: what it shows (tr() key), and the clue if it's still clean.
func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return "PRINTS_SHOWCASE_SMUDGED"
	case.found("prints")
	return "PRINTS_SHOWCASE"
