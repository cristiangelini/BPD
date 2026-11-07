class_name FarmRaidRig
extends Node

## What only one of the farm raid's stories adds (allanamiento-granja.md, "Las historias"), like GymRaidRig for the
## gym. The farm adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then
## run its own mechanic every frame.

var farm: FarmRaid


func setup(place: FarmRaid) -> void:
	farm = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
