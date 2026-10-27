class_name PlanetariumDirector
extends StaticBody3D

## Doctor Órbita, the director (escena-planetario.md, "El lugar"): lab coat, huge round glasses, wild grey hair and a
## pointer. E on him, he explains something about the sky nobody asked about, a different line each time. Every number
## here is (propuesta).

const MODEL := preload("res://assets/models/npc_orbita.glb")
const LINES := 5

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("planetarium_director")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.1
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_DIRECTOR"


func use(_cop: Cop) -> void:
	say("DIRECTOR_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
