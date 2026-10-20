class_name InterrogationProp
extends StaticBody3D

## A piece of the interrogation room a cop can use (E) on the suspect's nerves (interrogatorio.md, "Las acciones"):
## the steel table to slam, the lamp to turn on his face, the light switch, and the coffee machine that fills a cup. Only while an interrogation is on (an InterrogationCase in
## the tree); in any other case it's plain furniture.

## The InterrogationCase.ACTIONS id this prop does, or "pour_coffee".
var action := ""


func prompt_key(_cop: Cop) -> String:
	var case := InterrogationCase.active(get_tree(), self)
	if not case or not case.is_on():
		return ""
	return "PROMPT_POUR_COFFEE" if action == "pour_coffee" else InterrogationCase.ACTIONS[action].prompt


func use(cop: Cop) -> void:
	var case := InterrogationCase.active(get_tree(), self)
	if case:
		case.use_prop(action, cop)
