class_name LighthouseLamp
extends Evidence

## The harbor lighthouse's lamp La Bruma stole (control-neblina.md, "Cómo es" 5 and 6): it's in his car's trunk, and
## once he's cuffed it's on its lid, still lit, glowing through the fog. In the patrol car's trunk it's +100 on a solved
## case (TrafficCase), like the wedding's gift envelopes, and just as tough: no hit takes its value off.

const MODEL := preload("res://assets/models/lighthouse_lamp.glb")
const KG := 6.0
const VALUE := 100.0
const GLOW := Color(1, 0.85, 0.45)
const GLOW_RANGE := 6.0
const GLOW_ENERGY := 2.5


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	full_value = VALUE
	safe_speed = INF
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.19
	cylinder.height = 0.55
	shape.shape = cylinder
	shape.position.y = cylinder.height / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	var light := OmniLight3D.new()
	light.name = "Glow"
	light.light_color = GLOW
	light.light_energy = GLOW_ENERGY
	light.omni_range = GLOW_RANGE
	light.position.y = 0.25
	add_child(light)
	var halo := FogCar.halo(GLOW)
	halo.scale = Vector3.ONE * 1.5
	halo.position.y = 0.25
	add_child(halo)


func _ready() -> void:
	super._ready()
	add_to_group("lighthouse_lamps")


## Online (PropSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_LIGHTHOUSE_LAMP"
