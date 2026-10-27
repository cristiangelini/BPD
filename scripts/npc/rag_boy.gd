class_name RagBoy
extends StaticBody3D

## Pompita (docs/diseno/allanamiento-lavadero.md, "Pompita, el chico de los trapos"), the boy who dries the cars at the
## tunnel's exit and never has a dry rag, and the car wash's gossip. He only talks to whoever brings him a chamois from
## the rag basket still dry: "¡Seca! Te cuento algo", and he tells where he saw Don Chorro hide something (`clue`, set
## by the story). Once per cop. E on him empty-handed only gets him wringing his rag. Every number here is (propuesta).

## A cop brought him a dry chamois and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_pompita.glb")
const IDLE_LINES := ["POMPITA_IDLE_1", "POMPITA_IDLE_2", "POMPITA_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops he already talked to (id -> true).
var listeners := {}
var has_told := false
## Dry chamois he got.
var chamois := 0
## What he said to the last one who brought him something, and how many times (online, the guests' Pompita says it too).
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
	var cloth := _chamois_of(cop)
	return "PROMPT_POMPITA_CHAMOIS" if cloth and cloth.dry else "PROMPT_POMPITA"


## E on him: with a dry chamois in hand, he takes it and, the first time, tells what he saw.
func use(cop: Cop) -> void:
	var cloth := _chamois_of(cop)
	if cloth == null:
		_say("POMPITA_AGAIN" if listeners.has(cop.get_instance_id()) else "POMPITA_RULES", 4.0)
		return
	if not cloth.dry:
		_tell("POMPITA_WET", 4.0)
		return
	(cop.get_node("Grabber") as Node).release()
	cloth.queue_free()
	chamois += 1
	if listeners.has(cop.get_instance_id()):
		_tell("POMPITA_THANKS", 4.0)
		return
	listeners[cop.get_instance_id()] = true
	if clue_speech == "":
		_tell("POMPITA_NOTHING", 6.0)
		return
	_tell(tr("POMPITA_WON") + " " + clue_speech, 9.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func _chamois_of(cop: Cop) -> Chamois:
	return (cop.get_node("Grabber") as Node).get("held") as Chamois


## What he says to whoever brought him something: online the guests' Pompita says it too.
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
