class_name HardwareRig
extends Node

## What only one of the hardware store's stories adds (ferreteria.md, "Las historias"), like GroomerRig for the pet
## salon. The store adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then
## set the store's main evidence and run its own mechanic every frame.

var store: HardwareStore


func setup(place: HardwareStore) -> void:
	store = place
