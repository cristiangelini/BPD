class_name HandDryer
extends StaticBody3D

## The hand dryer in the museum's bathroom (escena-museo.md, "La coartada del baño"): E on it, it blows (FSHHH) or, if
## this match it's broken (one of the bathroom's details), does nothing at all. Every number here is (propuesta).

const SIZE := Vector3(0.3, 0.35, 0.18)

## This match it doesn't work.
var broken := false
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = SIZE
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Museum.METAL
	mesh.material_override = material
	add_child(mesh)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 0.4, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 32
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_DRYER"


func use(_cop: Cop) -> void:
	_bubble.text = "DRYER_BROKEN" if broken else "DRYER_WORKS"
	_bubble.show()
	_bubble_left = 2.5


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
