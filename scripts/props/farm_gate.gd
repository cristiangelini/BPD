class_name FarmGate
extends Node3D

## The cow's corral gate at the farm raid (docs/diseno/allanamiento-granja.md, "La vaca Margarita"): a wooden gate
## WIDTH wide hinged at this node, running along +Z when closed and swinging out to +X. E opens or shuts it.
## `open_for` counts how long it's been open: past the cow's patience she walks out. Every number here is (propuesta).

signal toggled(open: bool)

const WIDTH := 3.0
const HEIGHT := 1.1
const SWING_TIME := 0.6
const WOOD := Color(0.62, 0.44, 0.26)

var is_open := false
## Seconds it has been open in a row (0 while shut).
var open_for := 0.0
var _panel: AnimatableBody3D


func _ready() -> void:
	_panel = AnimatableBody3D.new()
	_panel.sync_to_physics = false
	add_child(_panel)
	var build := PlaceBuilder.new(_panel)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.1, HEIGHT, WIDTH)
	shape.shape = box
	shape.position = Vector3(0, HEIGHT / 2, WIDTH / 2)
	_panel.add_child(shape)
	for y: float in [HEIGHT * 0.3, HEIGHT * 0.65, HEIGHT * 0.95]:
		build.mesh_box(Vector3(0, y, WIDTH / 2), Vector3(0.08, 0.12, WIDTH), WOOD)
	for z: float in [0.05, WIDTH / 2, WIDTH - 0.05]:
		build.mesh_box(Vector3(0, HEIGHT / 2, z), Vector3(0.1, HEIGHT, 0.1), WOOD)
	# The diagonal brace every farm gate has.
	var brace := BoxMesh.new()
	brace.size = Vector3(0.06, 0.1, Vector2(WIDTH, HEIGHT * 0.65).length())
	build.mesh(brace, Vector3(0, HEIGHT * 0.62, WIDTH / 2), WOOD, Vector3(atan2(HEIGHT * 0.65, WIDTH), 0, 0))


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GATE_CLOSE" if is_open else "PROMPT_GATE_OPEN"


func use(_cop: Cop) -> void:
	set_open(not is_open)


func set_open(open: bool) -> void:
	if open == is_open:
		return
	is_open = open
	if not open:
		open_for = 0.0
	var tween := create_tween()
	tween.tween_property(_panel, "rotation:y", PI / 2 if open else 0.0, SWING_TIME).set_trans(Tween.TRANS_SINE)
	toggled.emit(open)


func _physics_process(delta: float) -> void:
	if is_open:
		open_for += delta
