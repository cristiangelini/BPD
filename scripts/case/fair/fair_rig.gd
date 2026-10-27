class_name FairRig
extends Node

## What only one of the fun fair raid's stories adds (allanamiento-parque.md, "Las historias"), like GymRaidRig for the
## gym. The fair adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then
## set the fair's main evidence and run its own mechanic every frame.

var fair: Fair


func setup(place: Fair) -> void:
	fair = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
