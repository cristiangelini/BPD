class_name InterrogationProp
extends StaticBody3D

## A piece of the interrogation room a cop can use (E) on the suspect's nerves (interrogatorio.md, "Las acciones"):
## the steel table to slam, the lamp to turn on his face. Only while an interrogation is on (an InterrogationCase in
## the tree); in any other case it's plain furniture.

## The InterrogationCase.ACTIONS id this prop does.
var action := ""


func prompt_key(_cop: Cop) -> String:
	var case := InterrogationCase.active(get_tree())
	return InterrogationCase.ACTIONS[action].prompt if case and case.is_on() else ""


func use(cop: Cop) -> void:
	var case := InterrogationCase.active(get_tree())
	if case:
		case.act(action, cop)
