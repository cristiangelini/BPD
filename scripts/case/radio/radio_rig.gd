class_name RadioRig
extends Node

## What only one of the radio's stories adds (allanamiento-radio.md, "Las historias"), like CinemaRig for the cinema.
## The radio adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then set the
## radio's main evidence and run its own mechanic.

var radio: RadioStation


func setup(place: RadioStation) -> void:
	radio = place
