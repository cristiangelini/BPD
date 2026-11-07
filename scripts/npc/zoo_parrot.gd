class_name ZooParrot
extends StaticBody3D

## Don Pico, the zoo's parrot (escena-zoo.md, "El lugar"), on his perch by the keepers' hut. He repeats what he hears,
## a different line each time he is asked. He is the witness (step 6). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_pico.glb")
const LINES := 4

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("zoo_parrot")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = 0.25
	shape.shape = ball
	shape.position.y = 0.25
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 0.8
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ZOO_PARROT"


func use(_cop: Cop) -> void:
	say("PARROT_LINE_%d" % (_lines_said % LINES))
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
