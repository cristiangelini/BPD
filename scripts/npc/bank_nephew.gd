class_name BankNephew
extends CharacterBody3D

## El Oso's nephew (robo-banco-techo.md, step 1, decision 126): a kid in an orange hoodie and a backwards cap, sitting
## on a bench on the sidewalk across from the bank with the toy helicopter's remote in his hands, pretending to play.
## E on him gets one of his innocent lines, in turn. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_sobrino.glb")
## A kid: smaller than the grown-ups.
const SCALE := 0.8
## Sitting on the bench, this high.
const SEAT := 0.42
const SAY_TIME := 4.0
const LINES := 3

var next_line := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_nephew")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.3
	shape.shape = capsule
	shape.position.y = 0.65
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; the kid faces -Z like everyone else.
	_model.rotation.y = PI
	_model.scale = Vector3.ONE * SCALE
	_model.position.y = SEAT
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.7, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_NEPHEW"


## E: his innocent lines, one after the other.
func use(_cop: Cop) -> void:
	say("NEPHEW_%d" % (next_line % LINES + 1))
	next_line += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
