class_name SecurityMonitors
extends RingmasterCamera

## The museum's security desk (escena-museo.md, "Las pistas"): last night's recording, with two buttons side by side.
## The green one plays it: the culprit takes the piece down and his mustache stays put or comes off (the recording
## clue); the red one, right next to it, records over it. Built on the desk by Museum, so this only has the buttons.

const RECORD := Color(0.85, 0.2, 0.2)


func _ready() -> void:
	prompts = "PROMPT_MONITORS_"
	_button("play", Vector3.ZERO, PLAY)
	_button("delete", Vector3(0, 0, 0.1), RECORD)


func play(cop: Cop) -> void:
	if deleted:
		cop.show_hint("HINT_MONITORS_OVER")
	elif has_recording and case:
		case.found("recording")
		cop.show_hint("HINT_MONITORS_PLAY_" + ("REAL" if case.culprit().mustache else "FAKE"))
	else:
		cop.show_hint("HINT_MONITORS_NOTHING")


func delete(cop: Cop) -> void:
	if deleted:
		if cop:
			cop.show_hint("HINT_MONITORS_OVER")
		return
	deleted = true
	if cop:
		cop.show_hint("HINT_MONITORS_RECORDED")
	if has_recording and case:
		case.ruin("recording")
