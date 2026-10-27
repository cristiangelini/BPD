class_name CarWashRig
extends Node

## What only one of the car wash raid's stories adds (allanamiento-lavadero.md, "Las historias"), like RinkRig for the
## ice rink. The car wash adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then set the car wash's main evidence and run its own mechanic every frame.

var car_wash: CarWash


func setup(place: CarWash) -> void:
	car_wash = place


## Online, what the guests' rig takes from the host's (CarWash.net_state, step 8).
func net_state() -> Array:
	return []


func apply_net_state(_state: Array) -> void:
	pass
