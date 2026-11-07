class_name PassageDoor
extends AnimatableBody3D

## A door of a SecretPassage: the panel in the doorway, or what hides it in the room (the bookcase, the clock), or
## what opens it (the candelabra). E on it opens or closes the whole passage.

var passage: SecretPassage
## What E says while the passage is shut.
var prompt := ""
## Where it is shut, and how far it slides when open.
var shut_at := Vector3.ZERO
var slide := Vector3.ZERO
var _tween: Tween


func set_size(size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PASSAGE_CLOSE" if passage.is_open else prompt


func use(cop: Cop) -> void:
	passage.toggle(cop)


func move(open: bool, seconds: float) -> void:
	if slide == Vector3.ZERO:
		return
	if _tween:
		_tween.kill()
	var to := shut_at + (slide if open else Vector3.ZERO)
	if not is_inside_tree():
		position = to
		return
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "position", to, seconds)
