class_name SheetScrap
extends StaticBody3D

## The scrap of sheet caught on a nail of the Golden Mask's case (escena-teatro.md, "Las pistas"): white, with a piece
## of the culprit's embroidery on it. E takes a close look and notes which embroidery it is (TheaterClues.look_at_scrap).

var clues: TheaterClues


func _init(color := Color.WHITE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 0.2, 0.08)
	shape.shape = box
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3.ZERO, Vector3(0.14, 0.12, 0.01), Color(0.96, 0.96, 0.94))
	builder.mesh_box(Vector3(0.03, -0.02, 0.008), Vector3(0.05, 0.05, 0.005), color)
	builder.mesh_box(Vector3(-0.05, 0.05, 0.01), Vector3(0.01, 0.01, 0.04), Color(0.5, 0.5, 0.52))


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SHEET_SCRAP"


func use(cop: Cop) -> void:
	if clues:
		clues.look_at_scrap(cop)
