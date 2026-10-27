class_name PostParrot
extends StaticBody3D

## Cartita, the parrot of window 2 (escena-correo.md, "El lugar"): green with a yellow head, on its perch on the
## counter. It repeats what it hears; it's the witness (step 6). For now E on it only gets something it heard at the
## counter, a different line each time. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_loro.glb")
const LINES := 3

var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("post_parrot")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.35, 0.65, 0.35)
	shape.shape = box
	shape.position.y = 0.33
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.0
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PARROT"


func use(_cop: Cop) -> void:
	say("PARROT_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of its model by name (body, head, wing_left, wing_right, tail, perch).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D
