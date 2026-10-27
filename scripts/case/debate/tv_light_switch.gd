class_name TvLightSwitch
extends StaticBody3D

## The switch for the set's spots on the control room's console (politico-debate.md, step 4, decision 230): E turns on
## any spot the bought technician switched off (TvSabotage).

signal pressed


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.25, 0.12, 0.25)
	shape.shape = box
	add_child(shape)
	var lamp := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = box.size
	lamp.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.85, 0.2)
	lamp.material_override = material
	add_child(lamp)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SPOTS_ON"


func use(_cop: Cop) -> void:
	pressed.emit()
