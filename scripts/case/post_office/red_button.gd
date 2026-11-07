class_name RedButton
extends StaticBody3D

## The red button on the boss's office wall (escena-correo.md, "La clasificadora"): E stops the sorting machine while it
## runs, at the price of Doña Sellito's patience (SortingMachine.switch_off).

var post_office: PostOffice


func _init() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 0.5, 0.2)
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_RED_BUTTON"


func use(cop: Cop) -> void:
	if post_office and post_office.sorting:
		post_office.sorting.switch_off(cop)
