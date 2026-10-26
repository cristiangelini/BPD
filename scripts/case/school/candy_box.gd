class_name CandyBox
extends StaticBody3D

## The box of candies on the teacher's desk (politico-escuela.md, step 5, decision 210): E with empty hands puts a
## candy in them, for a pupil who cries.

const SIZE := Vector3(0.3, 0.16, 0.2)


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = SIZE
	mesh.mesh = cube
	var material := StandardMaterial3D.new()
	material.albedo_color = SchoolCandy.WRAPPER
	mesh.material_override = material
	add_child(mesh)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TAKE_CANDY"


func use(cop: Cop) -> void:
	var grabber: Grabber = cop.get_node("Grabber")
	if grabber.held:
		cop.show_hint("HINT_HANDS_FULL_CANDY")
		return
	var candy := SchoolCandy.new()
	cop.get_parent().add_child(candy)
	candy.global_position = cop.camera.global_position - cop.camera.global_basis.z * 0.6
	grabber.grab(candy)
