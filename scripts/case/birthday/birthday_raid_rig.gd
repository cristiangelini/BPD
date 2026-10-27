class_name BirthdayRaidRig
extends Node

## What only one of the birthday party raid's stories adds (allanamiento-cumple.md, "Las historias"), like GymRaidRig
## for the gym. The party adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then run its own mechanic.

var party: BirthdayRaid


func setup(place: BirthdayRaid) -> void:
	party = place


## Online, what the guests' rig takes from the host's.
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
