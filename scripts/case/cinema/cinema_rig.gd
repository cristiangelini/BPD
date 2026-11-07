class_name CinemaRig
extends Node

## What only one of the cinema's stories adds (allanamiento-cine.md, "Las historias"), like GarageRig for the garage.
## The cinema adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then set the
## cinema's main evidence and run its own mechanic.

var cinema: Cinema


func setup(place: Cinema) -> void:
	cinema = place
