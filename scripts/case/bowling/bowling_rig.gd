class_name BowlingRig
extends Node

## What only one of the bowling alley's stories adds (allanamiento-bolera.md, "Las historias"), like SupermarketRig for
## the supermarket. The alley adds the story's rig as a child once its hidden items are placed and calls setup; the rig
## can then set the main evidence and run its own mechanic every frame.

var alley: Bowling


func setup(place: Bowling) -> void:
	alley = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
