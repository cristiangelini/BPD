class_name ScaffoldButton
extends StaticBody3D

## A button of the hanging scaffold (docs/diseno/edificio.md, step 3): on its control box, down (-1) or up (1), and
## pressing the way it's already going stops it; or a call button at one end (`stop` 0 the street, 1 floor 30).

var scaffold: HangingScaffold
var way := 0
var stop := -1


func prompt_key(_cop: Cop) -> String:
	if stop >= 0:
		return "" if scaffold.at_stop == stop and not scaffold.moving() else "PROMPT_CALL_SCAFFOLD"
	if scaffold.direction == way:
		return "PROMPT_SCAFFOLD_STOP"
	if not scaffold.moving() and scaffold.at_stop == (1 if way > 0 else 0):
		return ""
	return "PROMPT_SCAFFOLD_UP" if way > 0 else "PROMPT_SCAFFOLD_DOWN"


func use(_cop: Cop) -> void:
	if stop >= 0:
		scaffold.call_to(stop)
	else:
		scaffold.press(way)
