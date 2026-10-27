class_name HotelPillow
extends StaticBody3D

## The little pillow on the hotel's reception desk (hotel-allanamiento.md, "Su distracción: la siesta"): E tucks it
## under don Bostezo's head and he sleeps a while.

const SIZE := Vector3(0.4, 0.12, 0.28)
const COLOR := Color(0.95, 0.72, 0.8)

var concierge: HotelConcierge


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var look := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = SIZE.x / 2
	mesh.height = SIZE.y
	mesh.radial_segments = 10
	mesh.rings = 4
	look.mesh = mesh
	look.scale = Vector3(1, 1, SIZE.z / SIZE.x)
	var material := StandardMaterial3D.new()
	material.albedo_color = COLOR
	look.material_override = material
	add_child(look)


func prompt_key(_cop: Cop) -> String:
	if not concierge or concierge.is_asleep() or concierge.is_cuffed():
		return ""
	return "PROMPT_HOTEL_PILLOW"


func use(_cop: Cop) -> void:
	if concierge:
		concierge.tuck_pillow()
