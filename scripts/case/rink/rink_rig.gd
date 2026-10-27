class_name RinkRig
extends Node

## What only one of the rink raid's stories adds (allanamiento-pista.md, "Las historias"), like FairRig for the fun
## fair. The rink adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then
## set the rink's main evidence and run its own mechanic every frame.

var rink: Rink


func setup(place: Rink) -> void:
	rink = place


## Online, what the guests' rig takes from the host's (Rink.net_state, step 8).
func net_state() -> Array:
	return []


func apply_net_state(_state: Array) -> void:
	pass
