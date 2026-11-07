class_name TrainKnot
extends StaticBody3D

## The knot on the rope that tied the showcase shut (escena-tren.md, "Las pistas"): the culprit tied it again on his
## way out, and a left-hander's knot turns the other way. If the knot is one of the case's clues, a photo of it
## (PhotoCamera, "photo_clues") tells the hand; E unties it, and then it tells nothing. Every number here is (propuesta).

const SIZE := Vector3(0.16, 0.16, 0.1)
const ROPE := Color(0.75, 0.6, 0.35)

var case: CrimeSceneCase
var is_clue := false
var untied := false
## The culprit's hand: the knot's loops lean to his side.
var left := false
var _loops: Node3D


func _ready() -> void:
	add_to_group("photo_clues")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	_loops = Node3D.new()
	add_child(_loops)
	var builder := PlaceBuilder.new(_loops)
	builder.mesh_box(Vector3.ZERO, Vector3(0.06, 0.06, 0.05), ROPE)
	for side: float in [-1.0, 1.0]:
		builder.mesh_box(Vector3(side * 0.05, 0.03, 0), Vector3(0.06, 0.02, 0.02), ROPE)
	builder.mesh_box(Vector3(0, -0.08, 0), Vector3(0.02, 0.12, 0.02), ROPE)
	_loops.rotation.z = 0.5 if left else -0.5


## What a photo can catch here: its checklist line and the knot to aim at, while it can still be read.
func photo_clues() -> Dictionary:
	if not is_clue or untied or not case or case.clues_found.has("knot"):
		return {}
	return {case.clue_line("knot"): [self]}


func add_clue(_line: String) -> void:
	if case:
		case.found("knot")


func prompt_key(_cop: Cop) -> String:
	return "" if untied else "PROMPT_TRAIN_KNOT"


## E: the rope falls loose, and the way the knot turned with it.
func use(cop: Cop) -> void:
	if untied:
		return
	untie()
	if is_clue and case and not case.clues_found.has("knot"):
		case.ruin("knot")
	elif cop:
		cop.show_hint("HINT_TRAIN_KNOT_UNTIED")


## The rope falls loose (a guest's knot follows the host's).
func untie() -> void:
	untied = true
	_loops.visible = false
