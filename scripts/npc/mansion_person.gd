class_name MansionPerson
extends StaticBody3D

## Someone at the mystery mansion (escena-mansion.md, "La gente"): a body the cops bump into, a model and a speech
## bubble. E on them says their next line (`lines` of them, keys `line_key` + number); each kind says what else.

## The model to show and how tall the body is.
var model: PackedScene
var height := 1.8
## What E says: the key of the prompt, and the lines' key without its number and how many there are.
var prompt := ""
var line_key := ""
var lines := 1
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = height
	shape.shape = capsule
	shape.position.y = height / 2
	add_child(shape)
	if model:
		_model = model.instantiate()
		add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, height + 0.5, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 800.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return prompt


func use(_cop: Cop) -> void:
	say_next()


## Their next line, a different one each time.
func say_next() -> void:
	say("%s%d" % [line_key, _lines_said % lines])
	_lines_said += 1


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


## A part of the model by name.
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
