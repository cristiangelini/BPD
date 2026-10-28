class_name GarageRig
extends Node

## What only one of the garage's stories adds (allanamiento-taller.md, "Las historias"), like GymRaidRig for the gym.
## The garage adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then set the
## garage's main evidence and run its own mechanic.

var garage: Garage


func setup(place: Garage) -> void:
	garage = place
