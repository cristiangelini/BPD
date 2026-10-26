class_name KeyHook
extends StaticBody3D

## One hook of the KeyBoard, so a cop aims at one key at a time; E asks the board.

var board: KeyBoard
var index := 0


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.12, 0.3, 0.06)
	shape.shape = box
	add_child(shape)


func prompt_key(cop: Cop) -> String:
	return board.prompt_key(index, cop)


func use(cop: Cop) -> void:
	board.take(index, cop)
