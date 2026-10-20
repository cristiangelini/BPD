class_name GroomerRig
extends Node

## What only one of the pet salon's stories adds (peluqueria.md, "Las historias"), like BakeryRig for the bakery.
## The salon adds the story's rig as a child once its dogs and hidden items are placed and calls setup; the rig can
## then set the salon's main evidence and run its own mechanic every frame.

var groomer: Groomer


func setup(place: Groomer) -> void:
	groomer = place
