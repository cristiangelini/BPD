class_name Breathalyzer
extends Grabbable

## The patrol car's breathalyzer (control-boda.md, "Cómo es", step 2): with it in hand, E on a stopped car's driver
## makes them blow (QueueCar.blow), and its screen shows what they blew, from 0.0 to 2.0, red over the limit.

const MODEL := preload("res://assets/models/breathalyzer.glb")
const KG := 0.3
## Bigger than a real one, so it reads in hand and on the ground.
const LOOK_SCALE := 1.5
const SIZE := Vector3(0.07, 0.22, 0.04)
## Over the screen, a hair in front of it.
const SCREEN_AT := Vector3(0, 0.12, 0.022)
const SOBER := Color(0.5, 1.0, 0.6)
const OVER := Color(1.0, 0.3, 0.25)

var screen: Label3D
## The last reading, -1 before anyone blew.
var reading := -1.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE * LOOK_SCALE
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * LOOK_SCALE
	add_child(model)
	screen = Label3D.new()
	screen.name = "Screen"
	screen.text = "-.-"
	screen.font_size = 32
	screen.pixel_size = 0.0012
	screen.outline_size = 0
	screen.modulate = SOBER
	screen.position = SCREEN_AT * LOOK_SCALE
	add_child(screen)


func _ready() -> void:
	add_to_group("breathalyzers")


## What a driver blew, on its screen: red over WeddingCar.DRUNK_ABOVE.
func show_reading(value: float) -> void:
	reading = value
	screen.text = WeddingCar.reading_text(value)
	screen.modulate = OVER if value > WeddingCar.DRUNK_ABOVE else SOBER


## Online (PropSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_BREATHALYZER"
