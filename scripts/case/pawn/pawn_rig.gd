class_name PawnRig
extends Node

## What only one of the pawn shop's stories adds (allanamiento-empenos.md, "Las historias"), like CostumeRig for the
## costume shop. The shop adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then set the shop's main evidence and run its own mechanic every frame. Online, what only the host's rig decides goes
## to the guests' in net_state (part of the shop's CaseSync state).

var shop: PawnShop


func setup(place: PawnShop) -> void:
	shop = place


func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass
