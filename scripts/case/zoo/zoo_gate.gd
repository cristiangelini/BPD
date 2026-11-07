class_name ZooGate
extends StaticBody3D

## An enclosure's gate at the zoo (escena-zoo.md): bars across the gap in the fence. The penguins' gate is the keepers'
## door: E opens and shuts it (to take Copito back to his floe). The animals' gates are padlocked until feeding time
## (step 5). Open, nothing stops anyone and the bars hide.

## "penguins", "monkey", "ostrich" or "elephant".
var kind := ""
var open := false
## The bars, hidden while open.
var bars: Node3D


func prompt_key(_cop: Cop) -> String:
	if kind != "penguins":
		return "PROMPT_ZOO_GATE_LOCKED"
	return "PROMPT_ZOO_GATE_SHUT" if open else "PROMPT_ZOO_GATE_OPEN"


func use(_cop: Cop) -> void:
	if kind == "penguins":
		set_open(not open)


func set_open(on: bool) -> void:
	open = on
	collision_layer = 0 if on else 1
	if bars:
		bars.visible = not on
