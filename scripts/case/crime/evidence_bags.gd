class_name EvidenceBags
extends StaticBody3D

## A roll of evidence bags on the jury's table (escena-del-crimen.md, "Las pistas"): E aiming at it with a clue in
## hand puts the clue in a bag (CrimeClueItem). E with empty hands just says how.

const ROLL := Color(0.85, 0.9, 1.0)
const BOX := Color(0.2, 0.35, 0.7)


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.4, 0.2, 0.3)
	shape.shape = box
	shape.position.y = 0.1
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.08, 0), Vector3(0.4, 0.16, 0.3), BOX)
	builder.mesh_box(Vector3(0, 0.17, 0), Vector3(0.3, 0.04, 0.22), ROLL)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_EVIDENCE_BAGS"


func use(cop: Cop) -> void:
	cop.show_hint("HINT_EVIDENCE_BAGS")
