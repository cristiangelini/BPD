class_name BunkDummy
extends StaticBody3D

## The pillow and the blanket on a cell's bunk in the garbage truck jailbreak (docs/diseno/fuga-basura.md, step 2):
## E with empty hands rolls them into a lump that looks like a sleeping cop, BUILD seconds standing by. The guard counts
## a built one as a prisoner (GarbageGuard), unless he looks at it up close for too long. E on a built one undoes it.

const MODEL := preload("res://assets/models/pillow_dummy.glb")
const BUILD := 3.0
## How far from the bunk the builder can be while rolling it.
const BUILD_REACH := 1.8

## Which cell's bunk it's on.
var cell := 0
var built := false
var builder: Cop
var build_left := 0.0
var _model: Node3D


func _ready() -> void:
	add_to_group("bunk_dummies")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 0.3, 0.5)
	shape.shape = box
	shape.position.y = 0.15
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_refresh()


func prompt_key(cop: Cop) -> String:
	if builder:
		return "PROMPT_DUMMY_ROLLING" if builder == cop else ""
	return "PROMPT_DUMMY_UNDO" if built else "PROMPT_DUMMY_BUILD"


func use(cop: Cop) -> void:
	if builder:
		return
	if built:
		undo()
		return
	if cop.get_node("Grabber").held:
		cop.show_hint("HINT_DUMMY_HANDS")
		return
	builder = cop
	build_left = BUILD


func _physics_process(delta: float) -> void:
	if not builder:
		return
	if not is_instance_valid(builder) or builder.global_position.distance_to(global_position) > BUILD_REACH:
		builder = null
		return
	build_left -= delta
	if build_left <= 0.0:
		builder = null
		built = true
		_refresh()


## Back to a pillow and a blanket (a catch, or E on it).
func undo() -> void:
	builder = null
	built = false
	_refresh()


## Only the lump shows: unbuilt, the pillow and the blanket are part of the bunk.
func _refresh() -> void:
	_model.visible = built
