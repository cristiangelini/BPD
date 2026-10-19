class_name KeyPot
extends StaticBody3D

## A pot by the front door. One of them, drawn with the case seed, keeps the door key (docs/diseno/allanamiento.md).

signal searched(found_key: bool)

var has_key := false


func use(cop: Cop) -> void:
	var found := has_key
	if found:
		has_key = false
		cop.has_key = true
	cop.show_hint("HINT_KEY_FOUND" if found else "HINT_POT_EMPTY")
	searched.emit(found)
