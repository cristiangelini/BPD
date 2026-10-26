class_name EmptyFrame
extends StaticBody3D

## The empty frame where the stolen piece hung (escena-museo.md, "Las pistas"). If the prints are one of the case's
## clues, the print kit (PrintKit, `dusted`) finds the culprit's on the gilt; a cop who touches it first (E) leaves his
## own on top, like the circus's fish bucket.

var case: CrimeSceneCase
var has_prints := false
## A cop touched it.
var touched := false


## `size` is the frame's width and height; it hangs flat against the wall.
func _init(size := Vector2(2.0, 1.4)) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size.x + 0.16, size.y + 0.08, 0.1)
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_EMPTY_FRAME"


## E: the cop runs a finger along the gilt and leaves his prints on it.
func use(cop: Cop) -> void:
	var spoils := has_prints and not touched and case and not case.clues_found.has("prints")
	touched = true
	if spoils:
		case.ruin("prints")
	cop.show_hint("HINT_FRAME_TOUCHED" if spoils else "HINT_FRAME_EMPTY")


## The print kit dusted it: what it shows (tr() key), and the clue if it's still clean.
func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return "PRINTS_FRAME_SMUDGED"
	case.found("prints")
	return "PRINTS_FRAME"
