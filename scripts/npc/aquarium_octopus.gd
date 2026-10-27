class_name AquariumOctopus
extends StaticBody3D

## Doña Tinta, the octopus lady (escena-acuario.md, "Las pistas"), in her dark tank: her body is the tank's glass, so
## E on the glass is E on her. She sits on the sand in front of her rock cave. E, she waves or points, a different one
## each time. Drawing the thief's tank animal for a crab and hiding when tapped come in step 5. Every number here is
## (propuesta).

const MODEL := preload("res://assets/models/octopus_tinta.glb")
const LINES := 3

## The size of her tank's glass, which is her body (Aquarium.TANK_SIZE), with its bottom at her feet.
var glass := Vector3(2.6, 2.2, 3.4)
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("aquarium_octopus")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = glass
	shape.shape = box
	shape.position.y = glass.y / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.position.y = 0.05
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = glass.y + 0.4
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_OCTOPUS"


func use(_cop: Cop) -> void:
	say("OCTOPUS_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
