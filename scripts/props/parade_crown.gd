class_name ParadeCrown
extends Evidence

## The parade queen's crown El Antifaz stole (control-desfile.md, "Cómo es" 6): it's hidden on his float, and once
## he's cuffed it's on the float's deck for a cop to take. In the patrol car's trunk it's +100 on a solved case
## (TrafficCase), like the circus's jewels, and just as tough: no hit takes its value off.

const MODEL := preload("res://assets/models/parade_crown.glb")
const KG := 2.0
const VALUE := 100.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	full_value = VALUE
	safe_speed = INF
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.14
	cylinder.height = 0.22
	shape.shape = cylinder
	shape.position.y = cylinder.height / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	super._ready()
	add_to_group("parade_crowns")


## Online (PropSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_PARADE_CROWN"
