class_name Ingredient
extends Grabbable

## An ingredient from the restaurant's pantry or walk-in fridge (infiltracion-restaurante.md, step 3, decision 174): a
## tomato, an onion, a lettuce, a fish or a bundle of pasta. Grabbed and dropped into a pot, a frying pan or a plate
## (KitchenVessel), it goes in. The host makes them from the crates (IngredientCrate) and the guests copy them (PropSync,
## net_setup).

const KINDS: Array[String] = ["tomato", "onion", "lettuce", "fish", "pasta"]
const MODELS := {
	"tomato": preload("res://assets/models/food_tomato.glb"),
	"onion": preload("res://assets/models/food_onion.glb"),
	"lettuce": preload("res://assets/models/food_lettuce.glb"),
	"fish": preload("res://assets/models/food_fish.glb"),
	"pasta": preload("res://assets/models/food_pasta.glb"),
}
const SIZES := {"tomato": Vector3(0.14, 0.13, 0.14), "onion": Vector3(0.13, 0.17, 0.13),
	"lettuce": Vector3(0.24, 0.16, 0.24), "fish": Vector3(0.42, 0.1, 0.08), "pasta": Vector3(0.26, 0.08, 0.08)}

var kind := "tomato"


func _ready() -> void:
	add_to_group("ingredients")
	mass = 0.3
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZES[kind]
	shape.shape = box
	add_child(shape)
	add_child((MODELS[kind] as PackedScene).instantiate())


## Online (PropSync): what a guest's copy needs before it's added.
func net_setup() -> Dictionary:
	return {"name": name, "kind": kind}
