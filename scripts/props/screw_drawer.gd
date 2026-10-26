class_name ScrewDrawer
extends StaticBody3D

## One of the 60 little drawers of the hardware store's screw wall (ferreteria.md, "Tornillos de oro"). E pulls it
## out, once: it stays open, showing what's inside. The story's rig decides what that is and what happens.

signal opened(cop: Cop)

## The drawer front: thin along x (the wall faces +x), its height and its width along z.
var size := Vector3(0.04, 0.25, 0.29)
var is_open := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "" if is_open else "PROMPT_SCREW_DRAWER"


func use(cop: Cop) -> void:
	if is_open:
		return
	is_open = true
	var pulled := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.2, size.y, size.z)
	pulled.mesh = mesh
	var look := StandardMaterial3D.new()
	look.albedo_color = Color(0.84, 0.75, 0.6)
	pulled.material_override = look
	pulled.position = Vector3(0.1, 0, 0)
	add_child(pulled)
	opened.emit(cop)
