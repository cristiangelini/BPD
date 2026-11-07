class_name FarmTractor
extends StaticBody3D

## Don Florencio's tractor, parked beside the barn (docs/diseno/allanamiento-granja.md). It only starts in the racing
## tractor story, which sets `startable`: then E on it says "start" and the story's rig takes it from there.

signal started(cop: Cop)

var startable := false


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_START_TRACTOR" if startable else ""


func use(cop: Cop) -> void:
	if startable:
		started.emit(cop)
