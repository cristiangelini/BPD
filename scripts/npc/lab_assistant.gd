class_name LabAssistant
extends StaticBody3D

## Pocha (docs/diseno/laboratorio.md, "Pocha"), the cake lab's assistant and its gossip. She only talks to whoever
## tries her new cake: E on her tray and the cop eats a sample (TASTE_TIME seconds with full hands, Cop.eat), and while
## the cop chews she tells what she saw the chef hide (`clue`, set by the story). Once per cop; a cop back for more only
## gets a smile. Every number here is (propuesta).

## A cop tried her cake and she told what she saw: the checklist line, already translated.
signal told(text: String)
## A cop ate one of her samples.
signal tasted(cop: Cop)

const MODEL := preload("res://assets/models/npc_pocha.glb")
const TASTE_TIME := 3.0
const IDLE_LINES := ["POCHA_IDLE_1", "POCHA_IDLE_2", "POCHA_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what she saw, and the longer thing she says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## What the sample says about the story, as a hint to whoever eats it ("" for none; set by the story).
var sample_hint := ""
## The cops who already tried a sample.
var tasters := {}
var has_told := false
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	return "PROMPT_POCHA_TASTED" if tasters.has(cop) else "PROMPT_POCHA_SAMPLE"


## E on her tray: the first time, the cop eats a sample and she tells; after that, only a smile.
func use(cop: Cop) -> void:
	if tasters.has(cop):
		_say("POCHA_AGAIN", 3.0)
		return
	tasters[cop] = true
	cop.eat(TASTE_TIME)
	if sample_hint != "":
		cop.show_hint(sample_hint)
	tasted.emit(cop)
	if clue_speech == "":
		_say("POCHA_NOTHING", 5.0)
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
			_since_idle = 0.0
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
