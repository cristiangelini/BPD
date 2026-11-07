class_name LootSpot
extends StaticBody3D

## A place where what was stolen could be hidden: at the circus (escena-circo.md, "La historia") the costume trunk,
## the culprit's caravan or the cannon; at the museum (escena-museo.md) the storage room, the culprit's locker or
## behind a painting. E searches it (the place's `search`): in one of them, drawn with the seed, the stolen thing turns
## up; in the others, nothing but junk.

## "trunk", "caravan" or "cannon" at the circus; "storage", "locker" or "painting" at the museum.
var spot := "trunk"
## The Circus or the Museum it belongs to.
var place: CrimeScenePlace
## Its prompt, when several spots share one (the mansion's six suitcases); else PROMPT_SEARCH_ and the spot.
var prompt := ""


func _init(size := Vector3(0.6, 0.6, 0.6)) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return prompt if prompt != "" else "PROMPT_SEARCH_" + spot


func use(cop: Cop) -> void:
	if place:
		place.call("search", spot, cop)
