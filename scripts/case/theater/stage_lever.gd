class_name StageLever
extends StaticBody3D

## The stage lever behind the curtain (escena-teatro.md, "La función que sigue"): E stops the show for a while, at the
## price of Maestro Bambalina's patience (TheaterShow.pull_lever).

var theater: Theater


func _init() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.4, 1.5, 0.5)
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_STAGE_LEVER"


func use(cop: Cop) -> void:
	if theater and theater.performance:
		theater.performance.pull_lever(cop)
