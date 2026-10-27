class_name TvPrompter
extends StaticBody3D

## The deputy's teleprompter in front of his lectern (politico-debate.md, step 4, decision 230): he reads whatever it
## says. The bought technician can change its text for nonsense (TvSabotage). E unplugs it (and plugs it back): with
## no teleprompter he improvises, and his clean answers are worth half (TvDebate). Every number here is (propuesta).

signal plugged_now(on: bool)

const MODEL := preload("res://assets/models/teleprompter.glb")

var plugged := true
var _text: Label3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 1.3, 0.5)
	shape.shape = box
	shape.position.y = 0.65
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.name = "Model"
	add_child(model)
	_text = Label3D.new()
	_text.name = "Text"
	_text.font_size = 22
	_text.pixel_size = 0.006
	_text.width = 360.0
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# On the glass, readable from the lectern (it faces -Z).
	_text.position = Vector3(0, 1.24, -0.08)
	_text.rotation = Vector3(-0.78, PI, 0)
	add_child(_text)
	show_text("TV_PROMPTER_OK")


func show_text(key: String) -> void:
	_text.text = key if plugged else ""


func text() -> String:
	return _text.text


## Online, a guest's: shows what the host's says, already translated or not.
func follow(on: bool, now: String) -> void:
	plugged = on
	_text.text = now


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_UNPLUG_PROMPTER" if plugged else "PROMPT_PLUG_PROMPTER"


func use(_cop: Cop) -> void:
	set_plugged(not plugged)


func set_plugged(on: bool) -> void:
	plugged = on
	show_text("TV_PROMPTER_OK")
	plugged_now.emit(on)
