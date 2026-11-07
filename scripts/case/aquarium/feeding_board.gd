class_name FeedingBoard
extends StaticBody3D

## The feeding board on the kitchen wall (escena-acuario.md, "La Gorda, escondida en el acuario"): who feeds which tank
## and when. The culprit rubbed out one row so nobody would check that tank. E reads it through, which takes a while
## (Aquarium.read_board): the rubbed-out row gives the tank if the pearl is in one; otherwise, everyone ate well.

var aquarium: Aquarium


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_FEEDING_BOARD"


func use(cop: Cop) -> void:
	if aquarium:
		aquarium.read_board(cop)
