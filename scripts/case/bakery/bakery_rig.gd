class_name BakeryRig
extends Node

## What only one of the bakery's stories adds (panaderia.md, "Las historias"), like StoryRig for the grandpa's house.
## The bakery adds the story's rig as a child once its goods and hidden items are placed and calls setup; the rig
## can then set the bakery's main evidence and run its own mechanic every frame.

var bakery: Bakery


func setup(place: Bakery) -> void:
	bakery = place
