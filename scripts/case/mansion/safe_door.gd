class_name SafeDoor
extends EmptyFrame

## The open door of doña Clotilde's safe in the study (escena-mansion.md, "Las pistas"). Like the museum's empty frame:
## if the prints are one of the case's clues, the print kit finds the culprit's on it; a cop who touches it first (E)
## leaves his own on top.


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SAFE"


func use(cop: Cop) -> void:
	var spoils := has_prints and not touched and case and not case.clues_found.has("prints")
	touched = true
	if spoils:
		case.ruin("prints")
	cop.show_hint("HINT_SAFE_TOUCHED" if spoils else "HINT_SAFE_EMPTY")


func dusted(_cop: Cop) -> String:
	if not has_prints:
		return "PRINTS_COPS_ONLY" if touched else ""
	if touched and not case.clues_found.has("prints"):
		return "PRINTS_SAFE_SMUDGED"
	case.found("prints")
	return "PRINTS_SAFE"
