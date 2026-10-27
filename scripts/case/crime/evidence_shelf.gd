class_name EvidenceShelf
extends StaticBody3D

## The empty spot on the evidence room's middle shelf (escena-comisaria.md, "Las pistas"), where what was stolen stood.
## If the prints are one of the case's clues, the print kit (PrintKit, `dusted`) finds the culprit's in the dust; a cop
## who touches it first (E) leaves his own on top.

const SIZE := Vector3(1.0, 0.3, 0.64)

var case: CrimeSceneCase
var has_prints := false
## A cop touched it.
var touched := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_EMPTY_SHELF"


## E: the cop has a look and leaves his prints in the dust.
func use(cop: Cop) -> void:
	var spoils := has_prints and not touched and case and not case.clues_found.has("prints")
	touched = true
	if spoils:
		case.ruin("prints")
	cop.show_hint("HINT_SHELF_TOUCHED" if spoils else "HINT_SHELF_EMPTY")


## The print kit dusted it: what it shows (tr() key), and the clue if it's still clean.
func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return "PRINTS_SMUDGED"
	case.found("prints")
	return "PRINTS_DUST"
