class_name ClubEvidenceSpot
extends StaticBody3D

## A piece of the club's evidence that stays put (infiltracion.md, step 6b): the printing press, photographed, or
## Doña Chela's bag, searched with E. ClubEvidence hears it.

var kind := "bag"
var evidence: ClubEvidence


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CLUB_" + kind


func use(cop: Cop) -> void:
	if kind == "press":
		cop.show_hint("HINT_CLUB_PRESS_PHOTO")
	elif multiplayer.is_server():
		evidence.mark(kind)


## The camera's flash (PhotoCamera).
func photographed(_cop: Cop) -> void:
	if kind == "press" and multiplayer.is_server():
		evidence.mark(kind)
