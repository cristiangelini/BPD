class_name PoolTap
extends StaticBody3D

## The tap on the rim of Galleta's empty pool (escena-circo.md, "Las pistas"). E opens it: the water runs over the
## pool's floor and carries away anything loose on it, like the culprit's hair if nobody bagged it first.

var circus: Circus


func _init() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.25, 0.4, 0.25)
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_POOL_TAP"


func use(cop: Cop) -> void:
	if circus:
		circus.open_tap(cop)
