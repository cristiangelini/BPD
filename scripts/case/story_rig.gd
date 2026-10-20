class_name StoryRig
extends RefCounted

## What only one story adds to the raid on top of what every story shares (historias.md, "Lo que comparten todas
## las historias"). Each CaseStory names its rig; the house calls these hooks while it builds the case.


## Right after the evidence and the drawers are placed.
func setup(_house: GrandpaHouse) -> void:
	pass


## Once the navigation map is ready, for clues that follow a path (like a trail to an item).
func place_trails(_house: GrandpaHouse, _map: RID) -> void:
	pass


## The story's own clue trail leads to this evidence index, so the shared clues leave it out; -1 for none.
func trail_item() -> int:
	return -1


## Optional checklist rows: [{"text": tr() key or formatted text, "done": bool}].
func extras(_house: GrandpaHouse) -> Array[Dictionary]:
	return []
