class_name IngredientCrate
extends StaticBody3D

## A crate of one ingredient on the pantry's or the fridge's floor (infiltracion-restaurante.md, step 3): E puts a new
## one on top of it, to grab. The host makes it (the guests' copies come from PropSync); with MAX_LOOSE of that kind
## already lying around the kitchen, it says there are enough.

const MODELS := {
	"tomato": preload("res://assets/models/kitchen_crate_tomato.glb"),
	"onion": preload("res://assets/models/kitchen_crate_onion.glb"),
	"lettuce": preload("res://assets/models/kitchen_crate_lettuce.glb"),
	"fish": preload("res://assets/models/kitchen_crate_fish.glb"),
	"pasta": preload("res://assets/models/kitchen_crate_pasta.glb"),
}
const SIZE := Vector3(0.6, 0.3, 0.4)
const MAX_LOOSE := 6

var kind := "tomato"
var _made := 0


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child((MODELS[kind] as PackedScene).instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CRATE_" + kind


## The ingredients of this kind lying loose in the level.
func loose() -> int:
	return get_tree().get_nodes_in_group("ingredients").filter(func(item: Node) -> bool:
		return (item as Ingredient).kind == kind and not item.is_queued_for_deletion()).size()


## Host: a new one on top of the crate.
func use(cop: Cop) -> void:
	if loose() >= MAX_LOOSE:
		cop.show_hint("HINT_CRATE_ENOUGH")
		return
	if not multiplayer.is_server():
		return
	var item := Ingredient.new()
	item.kind = kind
	item.name = "%s_%s_%d" % [name, kind, _made]
	_made += 1
	get_parent().add_child(item)
	item.global_position = global_position + global_basis.y * (SIZE.y + 0.15)
