class_name PrintShopRig
extends Node

## What only one of the print shop raid's stories adds (allanamiento-imprenta.md, "Las historias"), like NurseryRig
## for the nursery. The print shop adds the story's rig as a child once its hidden items are placed and calls setup;
## the rig can then set the shop's main evidence and run its own mechanic every frame.

var shop: PrintShop


func setup(place: PrintShop) -> void:
	shop = place


## Online, what the guests' rig takes from the host's (step 9).
func net_state() -> Array:
	return []


func apply_net_state(_state: Array) -> void:
	pass
