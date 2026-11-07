class_name EmptyFrame
extends StaticBody3D

## The empty frame where the stolen piece hung (escena-museo.md, "Las pistas"). If the prints are one of the case's
## clues, the print kit (PrintKit, `dusted`) finds the culprit's on the gilt; a cop who touches it first (E) leaves his
## own on top, like the circus's fish bucket. The wedding's empty ring box and the hotel suite's open safe work the same
## with their own texts (`keys`).

var case: CrimeSceneCase
var has_prints := false
## A cop touched it.
var touched := false
## Its texts: the prompt, the hints on E and what the print kit shows.
var keys := {"prompt": "PROMPT_EMPTY_FRAME", "touched": "HINT_FRAME_TOUCHED", "empty": "HINT_FRAME_EMPTY",
	"smudged": "PRINTS_FRAME_SMUDGED", "prints": "PRINTS_FRAME"}


## `size` is the frame's width and height; it hangs flat against the wall (the ring box's, its width and height).
func _init(size := Vector2(2.0, 1.4)) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size.x + 0.16, size.y + 0.08, 0.1)
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return keys.prompt


## E: the cop runs a finger along the gilt and leaves his prints on it.
func use(cop: Cop) -> void:
	var spoils := has_prints and not touched and case and not case.clues_found.has("prints")
	touched = true
	if spoils:
		case.ruin("prints")
	cop.show_hint(keys.touched if spoils else keys.empty)


## The print kit dusted it: what it shows (tr() key), and the clue if it's still clean.
func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return keys.smudged
	case.found("prints")
	return keys.prints
