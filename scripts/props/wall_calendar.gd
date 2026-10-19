class_name WallCalendar
extends StaticBody3D

## The grandpa's kitchen calendar (investigacion.md, "Las pistas"): E reads it, and its numbers open the safe.

signal read(text: String)

var text := ""
var was_read := false


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CALENDAR"


func use(cop: Cop) -> void:
	cop.show_hint(text)
	if not was_read:
		was_read = true
		read.emit(text)
