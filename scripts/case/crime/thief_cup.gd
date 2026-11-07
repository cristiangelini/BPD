class_name ThiefCup
extends StaticBody3D

## The thief's cup on the manager's desk (escena-oficina.md, "Las pistas"), half drunk, on its saucer: three of the
## case's clues come from it. The print kit finds the culprit's prints on it; E takes a sip, which tells how he takes
## his coffee (three sips and it's gone); its handle and the coffee ring under it point to the hand he held it with,
## for a photo (PhotoCamera, "photo_clues"). Picking it up to sip leaves the cop's prints on top and moves it off its
## ring. Every number here is (propuesta).

const SIPS := 3
const CUP := Color(0.97, 0.97, 0.95)
const COFFEE := Color(0.25, 0.15, 0.08)

var case: CrimeSceneCase
## The culprit's: whether his prints are a clue, how he takes his coffee and whether he's left-handed.
var has_prints := false
var coffee := "black"
var left := false
var sips_left := SIPS
## A cop picked it up to sip: his prints are on it and it's off its ring.
var touched := false
var _coffee_top: MeshInstance3D


func _ready() -> void:
	add_to_group("photo_clues")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.16, 0.12, 0.16)
	shape.shape = box
	shape.position.y = 0.06
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	var side := -1.0 if left else 1.0
	var ring := TorusMesh.new()
	ring.inner_radius = 0.04
	ring.outer_radius = 0.05
	builder.mesh(ring, Vector3(side * 0.12, 0.002, 0.02), COFFEE)
	builder.mesh(_cylinder(0.075, 0.008), Vector3(0, 0.004, 0), CUP)
	builder.mesh(_cylinder(0.045, 0.09), Vector3(0, 0.053, 0), CUP)
	builder.mesh(_cylinder(0.04, 0.004), Vector3(0, 0.085, 0), COFFEE)
	_coffee_top = get_child(get_child_count() - 1) as MeshInstance3D
	builder.mesh_box(Vector3(side * 0.06, 0.06, 0), Vector3(0.025, 0.045, 0.012), CUP)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_THIEF_CUP" if sips_left > 0 else "PROMPT_THIEF_CUP_EMPTY"


## E: the cop picks it up and takes a sip, and it tells him how the thief takes his coffee.
func use(cop: Cop) -> void:
	if sips_left == 0:
		cop.show_hint("HINT_CUP_EMPTY")
		return
	if not touched:
		touched = true
		if has_prints and case:
			case.ruin("prints")
		if case:
			case.ruin("handle")
	sips_left -= 1
	_coffee_top.position.y -= 0.025
	_coffee_top.visible = sips_left > 0
	cop.show_hint(tr("HINT_CUP_SIP") % tr("COFFEE_" + coffee))
	if case:
		case.found("coffee")


## The print kit dusted it: what it shows (tr() key), and the clue if it's still clean.
func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return "PRINTS_CUP_SMUDGED"
	case.found("prints")
	return "PRINTS_CUP"


## What a photo can catch here: the handle and the ring, while the cup is still where the thief left it.
func photo_clues() -> Dictionary:
	if touched or not case or not case.plan.clues.has("handle") or case.clues_found.has("handle"):
		return {}
	return {case.clue_line("handle"): [self]}


func add_clue(_line: String) -> void:
	if case:
		case.found("handle")


func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	return mesh
