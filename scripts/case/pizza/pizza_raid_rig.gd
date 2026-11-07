class_name PizzaRaidRig
extends Node

## What only one of the pizzeria raid's stories adds (allanamiento-pizzeria.md, "Las historias"), like GymRaidRig for
## the gym. The pizzeria adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then run its own mechanic every frame.

var pizzeria: PizzaRaid


func setup(place: PizzaRaid) -> void:
	pizzeria = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
