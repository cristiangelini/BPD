class_name GoldWatch
extends Evidence

## A fake gold watch, smuggled inside a hollow watermelon (control-frutas.md): the evidence. One in the patrol car's
## trunk is +100 on a solved case (TrafficCase). It's tough: no hit takes its value off.

const MODEL := preload("res://assets/models/gold_watch.glb")
const KG := 0.15
const VALUE := 100.0
## Bigger than a real one, so it reads from a cop's eyes and in hand.
const LOOK_SCALE := 1.6


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	full_value = VALUE
	safe_speed = INF
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.08, 0.03, 0.18) * LOOK_SCALE
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * LOOK_SCALE
	model.position.y = 0.015
	add_child(model)


func _ready() -> void:
	super._ready()
	add_to_group("gold_watches")


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_GOLD_WATCH"
