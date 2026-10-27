class_name ApartmentsRig
extends Node

## What only one of the Las Palomas building's stories adds (edificio.md, "Las historias"), like CakeLabRig for the
## cake lab. The building adds the story's rig as a child once its hidden items are placed and calls setup; the rig
## then sets the main evidence and runs its own mechanic.

var tower: ApartmentTower


func setup(place: ApartmentTower) -> void:
	tower = place
