class_name CostumeRig
extends Node

## What only one of the costume shop's stories adds (allanamiento-disfraces.md, "Las historias"), like InsuranceRig for
## the insurance office. The shop adds the story's rig as a child once its hidden items are placed and calls setup; the
## rig can then set the shop's main evidence and run its own mechanic every frame. Online, what only the host's rig
## decides goes to the guests' in net_state (part of the shop's CaseSync state).

var shop: CostumeShop


func setup(place: CostumeShop) -> void:
	shop = place


func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
