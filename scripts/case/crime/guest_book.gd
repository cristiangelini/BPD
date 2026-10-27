class_name GuestBook
extends StaticBody3D

## The guest book open on the reception desk (escena-hotel.md, "Las pistas"): last night's page has the 3 a.m.
## check-out's signature, leaning one way if the culprit is left-handed and the other way if not. A photo of it
## (PhotoCamera, "photo_clues") notes the signature; a cop who signs on that page (E with the pen) covers it.

const PAGE := Color(0.96, 0.94, 0.86)
const INK := Color(0.1, 0.12, 0.3)

var case: CrimeSceneCase
var has_signature := false
var signed_over := false


func _ready() -> void:
	add_to_group("photo_clues")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.45, 0.06, 0.32)
	shape.shape = box
	shape.position.y = 0.03
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.043, 0), Vector3(0.42, 0.006, 0.29), PAGE)
	# Lines of signatures on the page; the last one is last night's, leaning the culprit's way.
	var lean := 0.0
	if has_signature and case:
		lean = 0.5 if case.culprit().left else -0.5
	for i in 4:
		var stroke := BoxMesh.new()
		stroke.size = Vector3(0.12, 0.002, 0.008)
		var turn := lean if i == 3 else (-0.5 if i % 2 == 0 else 0.4) * 0.3
		builder.mesh(stroke, Vector3(-0.05, 0.047, -0.1 + i * 0.06), INK, Vector3(0, turn, 0))


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GUEST_BOOK"


## E: the cop signs too, on the same page.
func use(cop: Cop) -> void:
	var spoils := has_signature and not signed_over and case and not case.clues_found.has("signature")
	signed_over = true
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(-0.05, 0.048, 0.08), Vector3(0.16, 0.003, 0.03), INK)
	if spoils:
		case.ruin("signature")
	cop.show_hint("HINT_GUEST_BOOK_SIGNED")


## What a photo can catch here: its checklist line and the page, while the signature can still be read.
func photo_clues() -> Dictionary:
	if not has_signature or signed_over or not case or case.clues_found.has("signature"):
		return {}
	return {case.clue_line("signature"): [self]}


func add_clue(_line: String) -> void:
	if case:
		case.found("signature")
