class_name ZooDirector
extends StaticBody3D

## Doña Jaula, the zoo's director (escena-zoo.md, "El lugar"): a safari hat, a khaki shirt, binoculars and a whistle.
## E on her, she says something about the animals, a different line each time. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_jaula.glb")
const LINES := 5

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("zoo_director")
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
	return "PROMPT_ZOO_DIRECTOR"


func use(_cop: Cop) -> void:
	say("ZOO_DIRECTOR_LINE_%d" % (_lines_said % LINES))
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
