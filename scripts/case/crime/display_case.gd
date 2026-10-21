class_name DisplayCase
extends StaticBody3D

## The jury's display case where the Torre de Merengue stood (escena-del-crimen.md, "Las pistas"), empty. If the
## prints are one of the case's clues, the print kit (PrintKit, `dusted`) finds the culprit's, in merengue; a cop who
## touches it first (E) leaves his own on top.

const SIZE := Vector3(1.0, 1.0, 0.8)
const WOOD := Color(0.55, 0.38, 0.24)
const GLASS := Color(0.75, 0.9, 1.0, 0.35)
const PLATE := Color(0.97, 0.96, 0.93)

var case: CrimeSceneCase
var has_prints := false
## A cop touched it.
var touched := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE + Vector3(0.1, 0.06, 0.1)
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.03, 0), Vector3(SIZE.x + 0.1, 0.06, SIZE.z + 0.1), WOOD)
	var t := 0.04
	var mid := 0.06 + SIZE.y / 2
	builder.mesh_box(Vector3(0, 0.06 + SIZE.y - t / 2, 0), Vector3(SIZE.x, t, SIZE.z), GLASS)
	for side: float in [-1.0, 1.0]:
		builder.mesh_box(Vector3(side * (SIZE.x - t) / 2, mid, 0), Vector3(t, SIZE.y, SIZE.z), GLASS)
		builder.mesh_box(Vector3(0, mid, side * (SIZE.z - t) / 2), Vector3(SIZE.x, SIZE.y, t), GLASS)
	var plate := CylinderMesh.new()
	plate.top_radius = 0.3
	plate.bottom_radius = 0.3
	plate.height = 0.02
	builder.mesh(plate, Vector3(0, 0.08, 0), PLATE)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_DISPLAY_CASE"


## E: the cop has a look and leaves his prints on the glass.
func use(cop: Cop) -> void:
	var spoils := has_prints and not touched and case and not case.clues_found.has("prints")
	touched = true
	if spoils:
		case.ruin("prints")
	cop.show_hint("HINT_DISPLAY_TOUCHED" if spoils else "HINT_DISPLAY_EMPTY")


## The print kit dusted it: what it shows (tr() key), and the clue if it's still clean.
func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return "PRINTS_SMUDGED"
	case.found("prints")
	return "PRINTS_MERENGUE"
