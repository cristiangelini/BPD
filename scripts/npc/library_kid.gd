class_name LibraryKid
extends StaticBody3D

## Tomasito (escena-biblioteca.md, "Las pistas"): the boy in pajamas with dinosaurs who fell asleep reading in the
## children's corner, lying on the rug with his picture book. E on him, he mumbles in his sleep. Reading him a story to
## hear what he saw comes in step 5. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_tomasito.glb")
## A boy: the grown-up body, smaller.
const SIZE := 0.6
const MUMBLES := 3

var _bubble: Label3D
var _bubble_left := 0.0
var _mumbles := 0


func _ready() -> void:
	add_to_group("library_kid")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.7, 0.4, 1.1)
	shape.shape = box
	shape.position.y = 0.2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	# Lying on his back on the rug, head to -Z.
	model.scale = Vector3.ONE * SIZE
	model.rotation.x = -PI / 2
	model.position = Vector3(0, 0.25, 0.5)
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.0
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_KID"


func use(_cop: Cop) -> void:
	say("KID_MUMBLE_%d" % (_mumbles % MUMBLES))
	_mumbles += 1


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
