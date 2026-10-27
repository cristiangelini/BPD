class_name RadioMic
extends StaticBody3D

## The studio's microphone at the radio (allanamiento-radio.md, step 2): E speaks on air. While the "AL AIRE" light is
## on, the whole neighborhood hears it and a listener calls to complain; the radio decides that.

signal spoken(cop: Cop)

const SIZE := Vector3(0.2, 0.35, 0.2)


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_RADIO_MIC"


func use(cop: Cop) -> void:
	cop.show_hint("RADIO_MIC_LINE")
	spoken.emit(cop)
