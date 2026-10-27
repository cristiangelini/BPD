class_name FarmNephew
extends StaticBody3D

## Pancho, Don Florencio's nephew (docs/diseno/allanamiento-granja.md, "El chismoso"): 12 years old, he collects the
## eggs by the hen house and three of his hens got out. He only talks to the cops once HENS of them are back in the hen
## house's run (`cooped`, kept by the farm): then he tells what he saw his uncle hide (`clue`, set by the story). Once
## per case; before that E on him only gets his count. Every number here is (propuesta).

## He told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_pancho.glb")
const HENS := 3
const IDLE_LINES := ["PANCHO_IDLE_1", "PANCHO_IDLE_2", "PANCHO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## Hens in the run right now.
var cooped := 0
var has_told := false
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.2
	shape.shape = capsule
	shape.position.y = 0.6
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.6, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PANCHO"


## E on him: how many hens are still missing, or what he saw once they're all back.
func use(_cop: Cop) -> void:
	if cooped < HENS:
		_say(tr("PANCHO_HENS") % (HENS - cooped), 4.0)
		return
	if clue_speech == "":
		_say("PANCHO_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func _physics_process(delta: float) -> void:
	_since_idle += delta
	if _since_idle < IDLE_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= TALK_RANGE:
			_say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return


func _say(key: String, seconds := 3.0) -> void:
	_since_idle = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
