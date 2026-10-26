class_name BathroomSpot
extends StaticBody3D

## A spot in the museum's tiny bathroom (escena-museo.md, "La coartada del baño"): the sink, where a cop takes a good
## look at how the bathroom was last night (the alibi clue: the three true details), or the toilet, which a cop can
## use, and then the bathroom is as he left it, not as it was, and the alibi clue is lost.

## "sink" or "toilet".
var kind := "sink"
var museum: Museum


func _init(spot_kind := "sink", size := Vector3(0.5, 0.5, 0.6)) -> void:
	kind = spot_kind
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BATHROOM_" + kind


func use(cop: Cop) -> void:
	if kind == "toilet":
		museum.use_toilet(cop)
	else:
		museum.look_at_bathroom(cop)
