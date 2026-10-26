class_name FactoryRig
extends Node

## What only one of the doll factory's stories adds (fabrica.md, "Las historias"), like HardwareRig for the hardware
## store. The factory adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then set the factory's main evidence and run its own mechanic every frame.

var factory: DollFactory


func setup(place: DollFactory) -> void:
	factory = place
