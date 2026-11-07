class_name ReadingArmchair
extends StaticBody3D

## The reading room's red velvet armchair (escena-biblioteca.md, "El silencio"): E, a cop sits down to read a while
## and the library's noise goes down faster while they stay (LibraryNoise.start_reading). Sitting on it loses the
## hair the culprit left on it, if it's still there.

var library: Library


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ARMCHAIR_READ"


func use(cop: Cop) -> void:
	if library:
		library.read_in_armchair(cop)
