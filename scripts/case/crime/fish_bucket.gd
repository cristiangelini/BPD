class_name FishBucket
extends StaticBody3D

## Galleta's bucket of fish by her pool (escena-circo.md, "Las pistas"). If the prints are one of the case's clues, the
## print kit (PrintKit, `dusted`) finds the culprit's, with fish scales; a cop who grabs it first (E) leaves his own on
## top, like the pastry's display case.

const METAL := Color(0.35, 0.37, 0.42)
const FISH := Color(0.6, 0.68, 0.75)

var case: CrimeSceneCase
var has_prints := false
## A cop touched it.
var touched := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 0.45, 0.5)
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	var bucket := CylinderMesh.new()
	bucket.top_radius = 0.24
	bucket.bottom_radius = 0.19
	bucket.height = 0.4
	builder.mesh(bucket, Vector3(0, 0.2, 0), METAL)
	# A few fish tails sticking out.
	for i in 3:
		var tail := BoxMesh.new()
		tail.size = Vector3(0.03, 0.12, 0.08)
		builder.mesh(tail, Vector3(-0.08 + i * 0.08, 0.44, 0.02 * i), FISH, Vector3(0.3 * (i - 1), 0, 0))


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_FISH_BUCKET"


## E: the cop has a look and leaves his prints on the handle.
func use(cop: Cop) -> void:
	var spoils := has_prints and not touched and case and not case.clues_found.has("prints")
	touched = true
	if spoils:
		case.ruin("prints")
	cop.show_hint("HINT_BUCKET_TOUCHED" if spoils else "HINT_BUCKET_FISH")


## The print kit dusted it: what it shows (tr() key), and the clue if it's still clean.
func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return "PRINTS_FISH_SMUDGED"
	case.found("prints")
	return "PRINTS_FISH"
