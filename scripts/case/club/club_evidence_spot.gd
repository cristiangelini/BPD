class_name ClubEvidenceSpot
extends StaticBody3D

## A piece of the club's evidence that stays put (infiltracion.md, step 6b): the printing press, photographed, or
## Doña Chela's bag, searched with E; at the chapel, the organ's back and Ernesto's new car, photographed.
## ClubEvidence hears it.

var kind := "bag"
## Counts when photographed (otherwise, on E).
var photo := false
var prompt_prefix := "PROMPT_CLUB_"
var evidence: ClubEvidence


func prompt_key(_cop: Cop) -> String:
	return prompt_prefix + kind


func use(cop: Cop) -> void:
	if photo:
		cop.show_hint("HINT_CLUB_PRESS_PHOTO")
	elif multiplayer.is_server():
		evidence.mark(kind)


## The camera's flash (PhotoCamera).
func photographed(_cop: Cop) -> void:
	if photo and multiplayer.is_server():
		evidence.mark(kind)
