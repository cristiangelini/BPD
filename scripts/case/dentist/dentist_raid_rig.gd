class_name DentistRaidRig
extends Node

## What only one of the dental office raid's stories adds (allanamiento-dentista.md, "Las historias"), like GymRaidRig
## for the gym. The office adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then run its own mechanic every frame.

var office: DentistRaid


func setup(place: DentistRaid) -> void:
	office = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
