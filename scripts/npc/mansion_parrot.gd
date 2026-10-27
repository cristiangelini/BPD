class_name MansionParrot
extends StaticBody3D

## Don Plumas, the parrot of the drawing room (escena-gato.md, "Las pistas"), on the stand of his cage. Until the case
## gives him something to repeat (step 5), E on him only gets "¡Lorito bonito!". Every number here is (propuesta).

const MODEL := preload("res://assets/models/parrot.glb")

var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("mansion_parrot")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.3, 0.4, 0.3)
	shape.shape = box
	shape.position.y = 0.2
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 0.7
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PARROT"


func use(_cop: Cop) -> void:
	say("PARROT_PRETTY")


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
