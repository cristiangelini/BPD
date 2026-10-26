class_name CircusJewels
extends Evidence

## The jewelry store's loot El Peludo hid in his cage's straw (control-circo.md, "Cómo es" 6): once he's cuffed it's
## on the cage's floor for a cop to take. In the patrol car's trunk it's +100 on a solved case (TrafficCase), like the
## lighthouse lamp, and just as tough: no hit takes its value off.

const MODEL := preload("res://assets/models/jewel_sack.glb")
const KG := 3.0
const VALUE := 100.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	full_value = VALUE
	safe_speed = INF
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.34, 0.34, 0.34)
	shape.shape = box
	shape.position.y = 0.17
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	super._ready()
	add_to_group("circus_jewels")


## Online (PropSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_CIRCUS_JEWELS"
