class_name SoundGuy
extends StaticBody3D

## Toto, the karaoke's sound guy and its gossip (allanamiento-karaoke.md, "Rosaura y Toto"). He stands behind the
## console with his headphones on all day and hears nothing: E on him only gets a "¿Qué?". When a cop turns the volume
## down at the console he takes the headphones off for the first time in years and, happy, tells that cop where he saw
## Rosaura hide something (`clue`, set by the story). Once per cop. Every number here is (propuesta).

## A cop turned the volume down and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_toto.glb")
const SCALE := 0.85
const DEAF_LINES := ["TOTO_DEAF_1", "TOTO_DEAF_2", "TOTO_DEAF_3"]
const IDLE_LINES := ["TOTO_IDLE_1", "TOTO_IDLE_2", "TOTO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0
const SAY_TIME := 4.0

## The checklist line for what he saw and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops he already told something, and whether he told the clue.
var heard := {}
var has_told := false
var _since_idle := 0.0
var _idle_line := 0
var _deaf_line := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * SCALE
	add_child(model)
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
	return "PROMPT_TALK_TOTO"


## E on him: with the music on he hears nothing.
func use(_cop: Cop) -> void:
	say(DEAF_LINES[_deaf_line % DEAF_LINES.size()])
	_deaf_line += 1


## `cop` turned the volume down: the headphones come off and, the first time for that cop, he talks.
func volume_down(cop: Cop) -> void:
	if heard.has(cop):
		say("TOTO_THANKS")
		return
	heard[cop] = true
	if clue_speech == "":
		say("TOTO_NOTHING", 6.0)
		return
	say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	_since_idle += delta
	if _since_idle < IDLE_EVERY or _bubble.visible:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		if (node as Node3D).global_position.distance_to(global_position) < TALK_RANGE:
			_since_idle = 0.0
			say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return
