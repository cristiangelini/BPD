class_name BankHostage
extends StaticBody3D

## A hostage of the bank robbery (robo-banco.md, step 2, decision 102): one of the neighbors who came to the bank,
## crouched on the hall's floor in front of the counter. E on one tells their complaint, a different one each time.
## Leading them out by the hand comes in step 4. Every number here is (propuesta).

const LOOKS: Array[String] = ["vecina", "clienta", "cliente", "senora", "abuelo", "abuela", "politico", "repartidor",
	"heladero", "periodista"]
const SCALES := {"abuelo": 0.82, "abuela": 0.8}
## Crouched on the floor: the model squashed this much.
const CROUCH := 0.82
const LINES := 8
const SAY_TIME := 4.0

@export var look := "vecina"
var next_line := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_hostages")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.3
	shape.shape = capsule
	shape.position.y = 0.65
	add_child(shape)
	var model: Node3D = load("res://assets/models/npc_%s.glb" % look).instantiate()
	var size: float = SCALES.get(look, 1.0)
	model.scale = Vector3(size, size * CROUCH, size)
	# The models face +Z; the hostage faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.6, 0)
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
	return "PROMPT_TALK_HOSTAGE"


func use(_cop: Cop) -> void:
	say("HOSTAGE_%d" % (next_line % LINES + 1))
	next_line += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
