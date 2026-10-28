class_name CakeBite
extends Node3D

## The bite out of the wedding cake's bottom tier (escena-boda.md, "Las pistas"): a photo of it (PhotoCamera,
## "photo_clues") notes the culprit's teeth. Cutting the cake open loses it (WeddingClues.cake_cut).

var case: CrimeSceneCase


## What a photo can catch here: its checklist line and the mark to aim at, while it's still there.
func photo_clues() -> Dictionary:
	if not visible or not case or case.clues_found.has("bite") or case.ruined.has("bite"):
		return {}
	return {case.clue_line("bite"): [self]}


func add_clue(_line: String) -> void:
	if case:
		case.found("bite")
