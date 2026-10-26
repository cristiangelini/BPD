class_name PushButton
extends StaticBody3D

## A big button on a wall or a post: E presses it and the place decides what it does (the doll factory's dock shutter,
## fabrica.md). It looks like a mushroom (red unless told otherwise) on a grey plate, facing +z.

signal pressed(cop: Cop)

const SIZE := Vector3(0.22, 0.22, 0.08)

## The text shown when a cop looks at it.
@export var prompt := "PROMPT_PUSH_BUTTON"
## The knob's color (the insurance office's printer has a green one).
@export var color := Color(0.85, 0.15, 0.12)
var presses := 0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var plate := BoxMesh.new()
	plate.size = Vector3(SIZE.x, SIZE.y, 0.03)
	_part(plate, Vector3.ZERO, Color(0.45, 0.47, 0.5))
	var knob := CylinderMesh.new()
	knob.top_radius = 0.06
	knob.bottom_radius = 0.06
	knob.height = 0.06
	_part(knob, Vector3(0, 0, 0.04), color).rotation.x = PI / 2


func _part(mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = at
	var look := StandardMaterial3D.new()
	look.albedo_color = color
	instance.material_override = look
	add_child(instance)
	return instance


func prompt_key(_cop: Cop) -> String:
	return prompt


func use(cop: Cop) -> void:
	presses += 1
	pressed.emit(cop)
