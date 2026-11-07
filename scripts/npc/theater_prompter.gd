class_name TheaterPrompter
extends StaticBody3D

## Don Susurro, the prompter (escena-teatro.md, "El lugar"): small and old, in his shell at the stage's edge, standing
## in the pit so only his head shows over the boards. E on him, he whispers, a different line each time. He is the
## witness (step 6). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_susurro.glb")
const LINES := 4

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("theater_prompter")
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
	return "PROMPT_PROMPTER"


func use(_cop: Cop) -> void:
	say("PROMPTER_LINE_%d" % (_lines_said % LINES))
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
