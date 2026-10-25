class_name LootSpot
extends StaticBody3D

## A place at the circus where what was stolen could be hidden (escena-circo.md, "La historia"): the costume trunk,
## the culprit's caravan or the cannon. E searches it (Circus.search): in one of them, drawn with the seed, the seal,
## the takings or the golden nose turn up; in the others, nothing but junk.

## "trunk", "caravan" or "cannon".
var spot := "trunk"
var circus: Circus


func _init(size := Vector3(0.6, 0.6, 0.6)) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SEARCH_" + spot


func use(cop: Cop) -> void:
	if circus:
		circus.search(spot, cop)
