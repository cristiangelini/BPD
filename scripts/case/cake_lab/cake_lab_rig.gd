class_name CakeLabRig
extends Node

## What only one of the cake lab's stories adds (laboratorio.md, "Las historias"), like InsuranceRig for the insurance
## office. The lab adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then
## set the lab's main evidence and run its own mechanic every frame.

var lab: CakeLab


func setup(place: CakeLab) -> void:
	lab = place
