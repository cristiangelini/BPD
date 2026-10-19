class_name ClueNote
extends Grabbable

## A note in the grandpa's hand (investigacion.md, "Las pistas"): E reads it, and it goes to the checklist.

signal read(text: String)

## The key prompt under the crosshair (the cookie tin uses its own).
@export var prompt := "PROMPT_NOTE"

var text := ""
var was_read := false


func prompt_key(_cop: Cop) -> String:
	return prompt


func use(cop: Cop) -> void:
	cop.show_hint(text)
	if not was_read:
		was_read = true
		read.emit(text)
