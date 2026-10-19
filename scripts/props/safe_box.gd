class_name SafeBox
extends Evidence

## The safe with the bingo takings (investigacion.md, "Qué hay que encontrar"). Closed, it is worth its full value but
## takes two cops to carry. Knowing the combination (the calendar or the cookie tin), E opens it: the takings come out
## as a light bundle anyone can take, and the empty safe is worth nothing.

signal opened(bundle: Evidence)

const BUNDLE_SCENE := preload("res://scenes/props/cash_bundle.tscn")

## Set by the house when the cops find the combination.
var code_known := false
var is_open := false
var bundle: Evidence


func prompt_key(_cop: Cop) -> String:
	if is_open:
		return ""
	return "PROMPT_SAFE_OPEN" if code_known else "PROMPT_SAFE_LOCKED"


func use(cop: Cop) -> void:
	if is_open:
		return
	if not code_known:
		cop.show_hint("HINT_SAFE_LOCKED")
		return
	is_open = true
	value = 0.0
	_show_value()
	bundle = BUNDLE_SCENE.instantiate()
	get_parent().add_child(bundle)
	bundle.global_position = global_position + global_basis.z * 0.5 + Vector3.UP * 0.1
	cop.show_hint("HINT_SAFE_OPENED")
	opened.emit(bundle)


func _show_value() -> void:
	super()
	if _label and is_open:
		_label.hide()
