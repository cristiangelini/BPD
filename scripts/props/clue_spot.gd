class_name ClueSpot
extends StaticBody3D

## A clue fixed to the place, like a ClueNote that can't be picked up (the doll factory's time clock): E looks at it,
## shows its text and sends it to the checklist once.

signal read(text: String)

## The box a cop aims at.
@export var size := Vector3(0.4, 0.5, 0.3)
@export var prompt := "PROMPT_NOTE"
var text := ""
var was_read := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return prompt


func use(cop: Cop) -> void:
	cop.show_hint(text)
	if not was_read:
		was_read = true
		read.emit(text)
