class_name KaraokeRig
extends Node

## What only one of the karaoke's stories adds (allanamiento-karaoke.md, "Las historias"), like BowlingRig for the
## bowling alley. The karaoke adds the story's rig as a child once its hidden items are placed and calls setup; the rig
## can then set the main evidence and run its own mechanic every frame.

var karaoke: Karaoke


func setup(place: Karaoke) -> void:
	karaoke = place


## The rig's flags the host decides and the guests' rig copies (the clue found, something that changed).
func shared() -> Array[String]:
	return []


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	var state := {}
	for key in shared():
		state[key] = get(key)
	return null if state.is_empty() else state


func apply_net_state(state: Variant) -> void:
	if state is Dictionary:
		for key: String in state:
			set(key, state[key])


## This PC's player's cop (offline, every cop): what only touches a player's own body or screen happens on their PC.
static func is_mine(cop: Cop) -> bool:
	return not cop.sync or not cop.sync.is_inside_tree() or cop.sync.is_multiplayer_authority()
