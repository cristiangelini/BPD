class_name CaseFolder
extends Grabbable

## The case folder, loose on the interrogation table (interrogatorio.md). In the twins' case, carried over and set
## down by the twin it wasn't last shown to, it's the bluff "your brother already talked" (InterrogationCase).

## How close to the twin it has to end up, in meters (propuesta): through the cell's bars too.
const REACH := 1.8
## A cop who let go of it this recently gets the credit.
const SHOWN_SECONDS := 3.0
const SETTLED_SPEED := 0.3

## The let go already checked, so it counts once each time it's set down.
var _checked_at := -1


func _physics_process(_delta: float) -> void:
	if not holders.is_empty() or let_go_at < 0 or let_go_at == _checked_at or linear_velocity.length() > SETTLED_SPEED:
		return
	_checked_at = let_go_at
	var case := InterrogationCase.active(get_tree(), self)
	if case:
		case.folder_shown(self)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_CASE_FOLDER"
