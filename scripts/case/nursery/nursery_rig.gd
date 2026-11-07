class_name NurseryRig
extends Node

## What only one of the nursery raid's stories adds (allanamiento-vivero.md, "Las historias"), like CarWashRig for the
## car wash. The nursery adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then set the nursery's main evidence and run its own mechanic every frame.

var nursery: Nursery


func setup(place: Nursery) -> void:
	nursery = place


## Online, what the guests' rig takes from the host's (step 9).
func net_state() -> Array:
	return []


func apply_net_state(_state: Array) -> void:
	pass
