class_name ConeDispenser
extends StaticBody3D

## The tube of cones on the shop's till desk (docs/diseno/allanamiento-heladeria.md, "Lucho"): E with empty hands puts
## an ice cream cone in them. Online only the host's makes it (PropSync copies it), like the school's candy box.

const SIZE := Vector3(0.14, 0.5, 0.14)
const COLOR := Color(0.6, 0.42, 0.28)


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var tube := CylinderMesh.new()
	tube.top_radius = SIZE.x / 2
	tube.bottom_radius = SIZE.x / 2
	tube.height = SIZE.y
	mesh.mesh = tube
	var material := StandardMaterial3D.new()
	material.albedo_color = COLOR
	mesh.material_override = material
	add_child(mesh)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TAKE_CONE"


func use(cop: Cop) -> void:
	if cop.sync and not cop.sync.net.is_host():
		return
	var grabber: Grabber = cop.get_node("Grabber")
	if grabber.held:
		cop.show_hint("HINT_HANDS_FULL_CONE")
		return
	var cone := IceCone.new()
	cop.get_parent().add_child(cone)
	cone.global_position = cop.camera.global_position - cop.camera.global_basis.z * 0.6
	grabber.grab(cone)
	SchoolPupil.tell_hands(cop)
