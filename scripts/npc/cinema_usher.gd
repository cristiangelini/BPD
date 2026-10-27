class_name CinemaUsher
extends StaticBody3D

## Chicho (docs/diseno/allanamiento-cine.md, "Chicho"), the cinema's usher and its gossip. He sits in the theater
## watching the film and only whispers to a cop who sits in the seat next to him and stays there SIT_SECONDS without
## getting up: then he tells what he saw doña Bobina hide (`clue`, set by the story). A cop who gets up sooner gets
## "¡Shhh, que viene lo mejor!" and has to start again. Once per cop. Every number here is (propuesta).

## A cop sat it out and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_chicho.glb")
const SIT_SECONDS := 8.0
const IDLE_LINES := ["CHICHO_IDLE_1", "CHICHO_IDLE_2", "CHICHO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 4.0

## The checklist line for what he saw, and the longer thing he whispers (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The seat next to him (set by the cinema before he's added).
var side_seat: CinemaSideSeat
## The cops he already whispered to.
var listeners := {}
var has_told := false
## How long the cop next to him has sat still.
var sat_for := 0.0
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 1.3, 0.6)
	shape.shape = box
	shape.position.y = 0.65
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.position.y = -CinemaSpectator.SIT_DROP
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.7, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 34
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	if side_seat:
		side_seat.sat.connect(func(_cop: Cop) -> void: sat_for = 0.0)
		side_seat.stood.connect(_on_stood)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CHICHO"


## E on him: he only points at the seat next to him.
func use(cop: Cop) -> void:
	_say("CHICHO_AGAIN" if listeners.has(cop) else "CHICHO_SIT", 4.0)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _on_stood(cop: Cop) -> void:
	if sat_for > 0.0 and not listeners.has(cop):
		_say("CHICHO_EARLY", 3.0)
	sat_for = 0.0


## The cop next to him sat it out: he whispers what he saw, once per cop.
func _tell(cop: Cop) -> void:
	listeners[cop] = true
	if clue_speech == "":
		_say("CHICHO_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func _physics_process(delta: float) -> void:
	var cop := side_seat.sitter if side_seat else null
	if cop and not listeners.has(cop):
		sat_for += delta
		if sat_for >= SIT_SECONDS:
			sat_for = 0.0
			_tell(cop)
		return
	_since_idle += delta
	if _since_idle < IDLE_EVERY:
		return
	for near in get_tree().get_nodes_in_group("cops"):
		if (near as Node3D).global_position.distance_to(global_position) <= TALK_RANGE:
			_say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return


func _say(key: String, seconds := 3.0) -> void:
	_since_idle = 0.0
	_bubble.text = key
	_bubble.show()
	var said_now := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said_now:
			_bubble.hide())
