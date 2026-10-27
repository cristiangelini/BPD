class_name MansionLady
extends StaticBody3D

## Señora Ofelia Monedero (escena-gato.md, "El lugar"): the richest woman in the city, in her silk dressing gown and
## pearls, fanning herself in the hall. E on her, she talks about Duquesa and about how much everything costs, a
## different line each time. Her patience comes in step 5. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_ofelia.glb")
const LINES := 5

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("mansion_lady")
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
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MANSION_LADY"


func use(_cop: Cop) -> void:
	say("MANSION_LADY_LINE_%d" % (_lines_said % LINES))
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
