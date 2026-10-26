class_name ScrewShelf
extends AnimatableBody3D

## The hardware store's screw wall (ferreteria.md, "El local"): one wooden cabinet with 60 little drawer fronts, its
## origin on the floor in its middle, its front facing +x. In the tunnel story (TunnelRig) it slides: two cops pushing
## with E at once (within PAIR_WINDOW of each other) move it SLIDE meters along -z and uncover what's behind it; one
## alone can't. Every number here is (propuesta).

signal slid(cop: Cop)
signal pushed_alone(cop: Cop)

const PAIR_WINDOW := 1.5
const SLIDE := 1.6
const SLIDE_TIME := 1.2

## Whether it can be slid at all (only in the tunnel story).
var slides := false
var is_open := false
## Cop -> seconds since they last pushed.
var _pushes := {}


func build(size: Vector3, rows: int, columns: int, wood: Color, front: Color) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = Vector3(0, size.y / 2, 0)
	add_child(shape)
	var parts := PlaceBuilder.new(self)
	parts.mesh_box(Vector3(0, size.y / 2, 0), size, wood)
	var step := Vector2(size.z / columns, size.y / rows)
	for row in rows:
		for column in columns:
			parts.mesh_box(Vector3(size.x / 2 + 0.01, (row + 0.5) * step.y, -size.z / 2 + (column + 0.5) * step.x),
				Vector3(0.02, step.y - 0.05, step.x - 0.05), front)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PUSH_SHELF" if slides and not is_open else ""


func use(cop: Cop) -> void:
	if not slides or is_open:
		return
	_pushes[cop] = 0.0
	if _pushes.size() >= 2:
		slide(cop)
	else:
		cop.show_hint("HINT_SHELF_HEAVY")
		pushed_alone.emit(cop)


## Moves it aside, for good.
func slide(cop: Cop = null) -> void:
	if is_open:
		return
	is_open = true
	_pushes.clear()
	create_tween().tween_property(self, "position", position + Vector3(0, 0, -SLIDE), SLIDE_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	slid.emit(cop)


func _physics_process(delta: float) -> void:
	for cop: Variant in _pushes.keys():
		_pushes[cop] += delta
		if not is_instance_valid(cop) or _pushes[cop] > PAIR_WINDOW:
			_pushes.erase(cop)
