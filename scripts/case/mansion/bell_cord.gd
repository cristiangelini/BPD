class_name BellCord
extends StaticBody3D

## The bell cord hanging in a room of the mansion (escena-mansion.md, "Las pistas"): E pulls it and its bell rings on
## the board in the butler's pantry, which mixes up the board's little flags (and the bells clue with them).

signal pulled(room: String)

const RED := Color(0.6, 0.1, 0.12)
const GOLD := Color(0.85, 0.7, 0.3)

## The room it rings for (Mansion.BELL_ROOMS).
var room := ""


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.15, 1.3, 0.15)
	shape.shape = box
	shape.position.y = 1.75
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 1.85, 0), Vector3(0.04, 1.1, 0.04), RED)
	builder.mesh_box(Vector3(0, 1.22, 0), Vector3(0.09, 0.16, 0.09), GOLD)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BELL_CORD"


func use(cop: Cop) -> void:
	if cop:
		cop.show_hint("HINT_BELL_RANG")
	pulled.emit(room)
