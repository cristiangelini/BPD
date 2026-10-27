class_name ResurfacerDriver
extends StaticBody3D

## Copito (docs/diseno/allanamiento-pista.md, "Copito, el chico de la pulidora"), the boy who drives the rink's
## resurfacer and is cold all day, and the rink's gossip. He only talks to whoever brings him a hot chocolate from the
## bar still full: "¡Calentito! Te cuento algo", and he tells where he saw Doña Pirueta hide something (`clue`, set by
## the story). Once per cop. E on him empty-handed only gets him shivering. Every number here is (propuesta).

## A cop brought him a full hot chocolate and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_copito.glb")
const IDLE_LINES := ["COPITO_IDLE_1", "COPITO_IDLE_2", "COPITO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops he already talked to (id -> true).
var listeners := {}
var has_told := false
## Hot chocolates he got.
var cups := 0
## What he said to the last one who brought him something, and how many times (online, the guests' Copito says it too).
var news := ""
var news_count := 0
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
	var cup := _cup_of(cop)
	return "PROMPT_COPITO_COCOA" if cup and cup.full else "PROMPT_COPITO"


## E on him: with a full hot chocolate in hand, he takes it and, the first time, tells what he saw.
func use(cop: Cop) -> void:
	var cup := _cup_of(cop)
	if cup == null:
		_say("COPITO_AGAIN" if listeners.has(cop.get_instance_id()) else "COPITO_RULES", 4.0)
		return
	if not cup.full:
		_tell("COPITO_EMPTY", 4.0)
		return
	(cop.get_node("Grabber") as Node).release()
	cup.queue_free()
	cups += 1
	if listeners.has(cop.get_instance_id()):
		_tell("COPITO_THANKS", 4.0)
		return
	listeners[cop.get_instance_id()] = true
	if clue_speech == "":
		_tell("COPITO_NOTHING", 6.0)
		return
	_tell(tr("COPITO_WON") + " " + clue_speech, 9.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func _cup_of(cop: Cop) -> CocoaCup:
	return (cop.get_node("Grabber") as Node).get("held") as CocoaCup


## What he says to whoever brought him something: online the guests' Copito says it too.
func _tell(line: String, seconds: float) -> void:
	news = line
	news_count += 1
	_say(line, seconds)


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
