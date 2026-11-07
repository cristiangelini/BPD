class_name Till
extends StaticBody3D

## Marta's cash register on the counter (docs/diseno/panaderia.md, "El local"): E opens its drawer, and the key to
## the bakehouse is inside. Marta doesn't like anyone touching her till.

signal opened(at: Vector3)

const SIZE := Vector3(0.5, 0.3, 0.4)
const COLOR := Color(0.6, 0.62, 0.66)
const DRAWER := Color(0.35, 0.36, 0.4)

var has_key := true
## What the cop reads on finding the key (each place names its locked door).
var key_hint := "HINT_TILL_KEY"
## A model to show instead of the grey register (Chispita's case of tricks at the birthday party); its drawer only
## shows once open.
var look: PackedScene
var is_open := false
var _drawer: MeshInstance3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	if look:
		var model: Node3D = look.instantiate()
		model.position.y = -SIZE.y / 2
		add_child(model)
	else:
		add_child(_mesh(SIZE, COLOR))
	_drawer = _mesh(Vector3(SIZE.x * 0.8, 0.08, SIZE.z), DRAWER)
	_drawer.position = Vector3(0, -SIZE.y / 2 + 0.05, 0)
	_drawer.visible = not look
	add_child(_drawer)


func prompt_key(_cop: Cop) -> String:
	return "" if is_open else "PROMPT_TILL"


func use(cop: Cop) -> void:
	if is_open:
		return
	is_open = true
	# The drawer slides out toward the cop's side of the counter (the till's +Z).
	_drawer.position.z = SIZE.z * 0.6
	_drawer.visible = true
	if has_key:
		has_key = false
		cop.has_key = true
		cop.show_hint(key_hint)
	opened.emit(global_position)


func _mesh(size: Vector3, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	look.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	look.material_override = material
	return look
