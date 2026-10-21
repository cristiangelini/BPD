class_name TowHook
extends StaticBody3D

## The tow truck's hook (persecucion-lugares.md, "La grúa"): once the driver gave up, E on it unhooks the patrol car
## (ChaseCase.unhook).

func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.8, 0.8, 0.8)
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_UNHOOK"


func use(cop: Cop) -> void:
	var case := get_tree().get_first_node_in_group("chase") as ChaseCase
	if case:
		case.unhook(cop)
