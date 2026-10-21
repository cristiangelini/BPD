class_name BoardStamp
extends StaticBody3D

## The rubber stamp "CULPABLE" on a desk in the board room (CrimeBoard): E on it takes it, and E on a file with it
## accuses that cook.

const DESK := Color(0.45, 0.32, 0.2)
const RUBBER := Color(0.8, 0.12, 0.1)
const HANDLE := Color(0.3, 0.2, 0.12)

var board: CrimeBoard


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 0.9, 0.6)
	shape.shape = box
	shape.position.y = 0.45
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.85, 0), Vector3(1.0, 0.06, 0.6), DESK)
	builder.legs(Vector3.ZERO, Vector2(1.0, 0.6), 0.82, DESK)
	builder.mesh_box(Vector3(0, 0.92, 0), Vector3(0.14, 0.05, 0.09), RUBBER)
	builder.mesh_box(Vector3(0, 1.0, 0), Vector3(0.05, 0.12, 0.05), HANDLE)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BOARD_STAMP"


func use(cop: Cop) -> void:
	board.stamp_by = cop
	cop.show_hint("HINT_BOARD_STAMP")
