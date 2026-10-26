class_name GymRaidRig
extends Node

## What only one of the gym raid's stories adds (allanamiento-gimnasio.md, "Las historias"), like CakeLabRig for the
## cake lab. The gym adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then
## set the gym's main evidence and run its own mechanic every frame.

var gym: GymRaid


func setup(place: GymRaid) -> void:
	gym = place
