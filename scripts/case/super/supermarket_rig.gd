class_name SupermarketRig
extends Node

## What only one of the supermarket's stories adds (allanamiento-super.md, "Las historias"), like GymRaidRig for the
## gym. The supermarket adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then set the main evidence and run its own mechanic every frame.

var store: Supermarket


func setup(place: Supermarket) -> void:
	store = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
