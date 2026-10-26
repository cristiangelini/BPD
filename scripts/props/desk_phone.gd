class_name DeskPhone
extends StaticBody3D

## A phone on a cubicle desk (seguros.md, "El seguro contra ovnis"): it rings now and then, and E answers it. On the
## line is always a retiree with a UFO policy asking something absurd ("does it cover cows?").

signal answered(cop: Cop)

## What the callers say, one per answer in turn (set by the rig; translated keys).
var calls: Array[String] = []
var answers := 0

@onready var _ring: Label3D = $Ring


func is_ringing() -> bool:
	return _ring.visible


func ring() -> void:
	_ring.show()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PHONE" if is_ringing() else ""


func use(cop: Cop) -> void:
	if not is_ringing():
		return
	_ring.hide()
	if not calls.is_empty():
		cop.show_hint(calls[answers % calls.size()])
	answers += 1
	answered.emit(cop)
