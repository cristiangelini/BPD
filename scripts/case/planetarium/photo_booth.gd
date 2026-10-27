class_name PhotoBooth
extends StaticBody3D

## The gift shop's photo booth "Tu cara en la Luna" (escena-planetario.md, "Las pistas"), in two parts: the booth itself
## (E: the cop takes a photo of their own face on the Moon) and its tray (E: a look at the last photo). If the booth's
## photo is one of the case's clues, the last one is whoever took one at 3 in the morning, with their planet pin; a new
## photo before anyone looks covers it (PlanetariumClues).

var clues: PlanetariumClues
## The tray, not the booth.
var tray := false


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BOOTH_TRAY" if tray else "PROMPT_BOOTH_PHOTO"


func use(cop: Cop) -> void:
	if not clues:
		return
	if tray:
		clues.look_at_tray(cop)
	else:
		clues.take_photo(cop)
