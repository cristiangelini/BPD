class_name CandySeller
extends StaticBody3D

## Nube (docs/diseno/allanamiento-parque.md, "Nube, la vendedora de algodón de azúcar"), the fun fair's cotton candy
## seller, who also minds the cans booth, and its gossip. She only talks to whoever knocks down the 3 cans with the
## booth's 3 balls: "You won! There's no prize, but I'll tell you something", and she tells where she saw Don Tómbola
## hide something (`clue`, set by the story). Once per cop. E on her only gets the rules. Every number here is
## (propuesta).

## A cop won at the cans and she told what she saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_nube.glb")
const IDLE_LINES := ["NUBE_IDLE_1", "NUBE_IDLE_2", "NUBE_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what she saw, and the longer thing she says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops she already talked to.
var listeners := {}
var has_told := false
var _since_idle := 0.0
var _idle_line := 0
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
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_NUBE"


## E on her: the rules of the cans, or that she already told.
func use(cop: Cop) -> void:
	_say("NUBE_AGAIN" if listeners.has(cop) else "NUBE_RULES", 4.0)


## `cop` knocked down the 3 cans: the first time, she tells what she saw.
func won(cop: Cop) -> void:
	if listeners.has(cop):
		_say("NUBE_AGAIN", 4.0)
		return
	listeners[cop] = true
	if clue_speech == "":
		_say("NUBE_NOTHING", 6.0)
		return
	_say(tr("NUBE_WON") + " " + clue_speech, 9.0)
	if not has_told:
		has_told = true
		told.emit(clue)


## Some cans stayed up.
func missed() -> void:
	_say("NUBE_MISSED", 3.0)


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
