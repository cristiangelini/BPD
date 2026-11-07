class_name PrintShopRig
extends Node

## What only one of the print shop raid's stories adds (allanamiento-imprenta.md, "Las historias"), like NurseryRig
## for the nursery. The print shop adds the story's rig as a child once its hidden items are placed and calls setup;
## the rig can then set the shop's main evidence and run its own mechanic every frame.

var shop: PrintShop


func setup(place: PrintShop) -> void:
	shop = place


## Online, what the guests' rig takes from the host's (step 9): by default whether its clue was noticed there (the
## host sees the cops come close), and then the guests' rig notices too.
func net_state() -> Array:
	return [get("noticed") == true]


func apply_net_state(state: Array) -> void:
	if state[0] and get("noticed") == false and has_method("notice"):
		call("notice")


## The cops in the same order on every PC (by player), for what goes to each in turn.
func cops_in_turn() -> Array[Node]:
	var cops := get_tree().get_nodes_in_group("cops")
	cops.sort_custom(func(a: Node, b: Node) -> bool:
		return a.get_multiplayer_authority() < b.get_multiplayer_authority())
	return cops


## Whether `cop` is played on this PC (solo, every cop is): what only shows to its player, like a sticker on the face.
static func is_mine(cop: Cop) -> bool:
	return cop.sync == null or cop.sync.is_multiplayer_authority()
