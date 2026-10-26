class_name Mannequin
extends StaticBody3D

## A ghost worker of the doll factory (fabrica.md, "Los operarios fantasma"): a shop mannequin in a work coat standing
## at the belt as if working. E on it asks it something, and it never answers.

signal asked(cop: Cop)

const MODEL := preload("res://assets/models/npc_maniqui.glb")

var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.text = "MANNEQUIN_SILENCE"
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.font_size = 40
	_bubble.outline_size = 10
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ASK_WORKER"


func use(cop: Cop) -> void:
	_bubble.show()
	get_tree().create_timer(2.0).timeout.connect(_bubble.hide)
	cop.show_hint("HINT_MANNEQUIN")
	asked.emit(cop)
