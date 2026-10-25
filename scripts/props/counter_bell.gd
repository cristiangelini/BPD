class_name CounterBell
extends StaticBody3D

## The bell on the hardware store's counter (docs/diseno/ferreteria.md, "Su distracción"): a cop rings it with E and
## asks Tobías for "a 3/8 fine thread screw"; he turns to the screw wall and looks for it, not watching the shop.

const SIZE := Vector3(0.12, 0.08, 0.12)

var hardware_man: HardwareMan


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position = Vector3.UP * SIZE.y / 2
	add_child(shape)
	var dome := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = SIZE.x / 2
	mesh.height = SIZE.y * 1.4
	mesh.radial_segments = 8
	mesh.rings = 4
	dome.mesh = mesh
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(1.0, 0.82, 0.29)
	gold.metallic = 0.6
	dome.material_override = gold
	dome.position = Vector3.UP * SIZE.y * 0.3
	add_child(dome)


func prompt_key(_cop: Cop) -> String:
	if not hardware_man or hardware_man.is_searching():
		return ""
	return "PROMPT_SCREW_BELL"


func use(_cop: Cop) -> void:
	if hardware_man:
		hardware_man.look_for_screw()
