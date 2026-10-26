class_name GymRaidRig
extends Node

## What only one of the gym raid's stories adds (allanamiento-gimnasio.md, "Las historias"), like CakeLabRig for the
## cake lab. The gym adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then
## set the gym's main evidence and run its own mechanic every frame.

var gym: GymRaid


func setup(place: GymRaid) -> void:
	gym = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass


## This PC's player's cop (offline, every cop): what only touches a player's own body or screen happens on their PC.
static func is_mine(cop: Cop) -> bool:
	return not cop.sync or not cop.sync.is_inside_tree() or cop.sync.is_multiplayer_authority()
