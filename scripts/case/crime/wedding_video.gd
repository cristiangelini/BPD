class_name WeddingVideo
extends RingmasterCamera

## The wedding videographer's camera on its tripod by the dance floor (escena-boda.md, "Las pistas"): it was rolling
## when the stolen thing went. The green button plays it: the culprit walks off with it, glasses on or not (the recording
## clue); the red one, right next to it, deletes it.


func _ready() -> void:
	prompts = "PROMPT_VIDEO_"
	super._ready()


func play(cop: Cop) -> void:
	if deleted:
		cop.show_hint("HINT_VIDEO_DELETED")
	elif has_recording and case:
		case.found("recording")
		cop.show_hint("HINT_VIDEO_GLASSES" if case.culprit().glasses else "HINT_VIDEO_NO_GLASSES")
	else:
		cop.show_hint("HINT_VIDEO_NOTHING")
