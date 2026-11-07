class_name Librarian
extends StaticBody3D

## Doña Sigilo, the head librarian (escena-biblioteca.md, "El lugar"): plum cardigan, grey bun, glasses on a chain and
## her feather duster, behind the desk. E on her, she whispers about her library and its rules, a different line each
## time. The noise and her "¡SHHH!" come in step 5. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_sigilo.glb")
const LINES := 5

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("librarian")
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
	return "PROMPT_LIBRARIAN"


func use(_cop: Cop) -> void:
	say("LIBRARIAN_LINE_%d" % (_lines_said % LINES))
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
