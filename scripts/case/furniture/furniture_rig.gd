class_name FurnitureRig
extends Node

## What only one of the furniture store's stories adds (allanamiento-muebleria.md, "Las historias"), like GarageRig
## for the garage. The store adds the story's rig as a child once its hidden items are placed and calls setup; the rig
## can then set the store's main evidence and run its own mechanic.

var store: FurnitureStore


func setup(place: FurnitureStore) -> void:
	store = place
