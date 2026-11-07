class_name PizzaTito
extends StaticBody3D

## Tito (docs/diseno/allanamiento-pizzeria.md, "El chismoso"), the delivery boy with a helmet and roller skates who
## waits on the bench in the pizzeria's yard. He only talks to a cop who brings him a slice from the counter's tray
## (Don Muzza doesn't let him eat on the clock): E with the slice in hand and he eats it and tells where he saw Don
## Muzza hide something (`clue`, set by the story). Once per case; another slice only gets a thank you. Every number
## here is (propuesta).

## A cop brought him a slice and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_tito.glb")
const SLICE_GROUP := "pizza_slice"
const IDLE_LINES := ["TITO_IDLE_1", "TITO_IDLE_2", "TITO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
var has_told := false
var slices := 0
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
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


## The slice in `cop`'s hands, if any.
static func slice_of(cop: Cop) -> Grabbable:
	var held: Grabbable = cop.get_node("Grabber").held
	return held if held and held.is_in_group(SLICE_GROUP) else null


func prompt_key(cop: Cop) -> String:
	return "PROMPT_TITO_SLICE" if slice_of(cop) else "PROMPT_TITO"


## E on him: with a slice he eats it (and tells, the first time); without one he asks for it.
func use(cop: Cop) -> void:
	var slice := slice_of(cop)
	if not slice:
		_say("TITO_AGAIN" if has_told else "TITO_WANTS_SLICE", 4.0)
		return
	cop.get_node("Grabber").release()
	slice.hide()
	# Every PC runs this; the host's PropSync takes the slice away from the guests.
	if multiplayer.is_server():
		slice.queue_free()
	slices += 1
	if has_told:
		_say("TITO_THANKS", 4.0)
		return
	has_told = true
	if clue_speech == "":
		_say("TITO_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
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
