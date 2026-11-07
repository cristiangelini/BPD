class_name PizzaRaidRig
extends Node

## What only one of the pizzeria raid's stories adds (allanamiento-pizzeria.md, "Las historias"), like GymRaidRig for
## the gym. The pizzeria adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then run its own mechanic every frame.

var pizzeria: PizzaRaid


func setup(place: PizzaRaid) -> void:
	pizzeria = place


## Online, what the guests' rig takes from the host's (null: nothing).
func net_state() -> Variant:
	return null


func apply_net_state(_state: Variant) -> void:
	pass


## A thing lying at `at` (the pizzeria's space) that E looks at and puts on the checklist the first time: the
## story's own clue.
func clue_item(item_name: String, model: PackedScene, size: Vector3, at: Vector3, prompt: String, text_key: String) \
		-> ClueNote:
	var item := ClueNote.new()
	item.name = item_name
	item.prompt = prompt
	item.text = tr(text_key)
	item.collision_layer = 4
	item.collision_mask = 15
	item.mass = 0.15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	item.add_child(shape)
	item.add_child(model.instantiate())
	item.position = at
	item.read.connect(pizzeria.raid.add_clue)
	pizzeria.add_child(item)
	return item
