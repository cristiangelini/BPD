class_name Receptionist
extends StaticBody3D

## Coca (docs/diseno/seguros.md, "Coca"), the receptionist of "Seguros Todo Tranquilo" and the office's gossip. She
## doesn't talk to anyone without a number: a cop takes one at the ticket machine and she calls the next number every
## CALL_EVERY seconds. When she calls a cop's number and the cop is at the counter, she tells what she saw the floor
## boss hide (`clue`, set by the story); if the cop isn't there, the number is lost. Every number here is (propuesta).

## She called a number and the cop was at the counter: what she saw, as the checklist line, already translated.
signal told(text: String)
## She called `number` (to everyone in the reception).
signal called(number: int)

const MODEL := preload("res://assets/models/npc_recepcionista_seguros.glb")
## The number she's serving when the office opens, and the first ticket the machine gives.
const FIRST_SERVING := 41
const FIRST_TICKET := 47
const CALL_EVERY := 6.0
## A cop this close to the counter spot is "at the counter".
const COUNTER_RANGE := 1.6
const IDLE_LINES := ["COCA_IDLE_1", "COCA_IDLE_2", "COCA_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what she saw, and the longer thing she says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## Where a cop stands to be served, in the office's space (set by the office).
var counter_spot := Vector3.ZERO
var serving := FIRST_SERVING
var next_ticket := FIRST_TICKET - 1
var served := false
## The numbers the cops are holding, by cop.
var tickets := {}
var _since_call := 0.0
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D
var _board: Label3D


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
	# The "now serving" board over her head, facing the waiting room.
	_board = Label3D.new()
	_board.name = "Board"
	_board.position = Vector3(0, 2.55, 0.9)
	_board.pixel_size = 0.006
	_board.outline_size = 12
	_board.font_size = 64
	_board.modulate = Color(1.0, 0.35, 0.25)
	add_child(_board)
	_show_board()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_COCA"


## E on her: without a number she sends the cop to the machine; with one, she says who she's serving.
func use(cop: Cop) -> void:
	if served:
		_say(clue_speech if clue_speech != "" else "COCA_THANKS", 6.0)
		return
	if tickets.has(cop):
		_say(tr("COCA_WAIT") % [serving, tickets[cop]], 4.0)
	else:
		_say("COCA_TAKE_NUMBER", 4.0)


## The ticket machine gave `cop` a number (one at a time per cop). Returns it, or the one the cop already holds.
func take_ticket(cop: Cop) -> int:
	if tickets.has(cop):
		return tickets[cop]
	next_ticket += 1
	tickets[cop] = next_ticket
	return next_ticket


## The next number: if its cop is at the counter she tells; if not, the number is lost.
func call_next() -> void:
	serving += 1
	_since_call = 0.0
	_show_board()
	called.emit(serving)
	var holder: Variant = null
	for cop: Variant in tickets.keys():
		if tickets[cop] == serving:
			holder = cop
	if holder == null:
		_say(tr("COCA_CALL") % serving)
		return
	tickets.erase(holder)
	if not is_instance_valid(holder) or (holder as Cop).global_position.distance_to(_counter()) > COUNTER_RANGE:
		_say(tr("COCA_LOST") % serving, 4.0)
		return
	if served:
		_say("COCA_THANKS", 4.0)
		return
	served = true
	_say(clue_speech if clue_speech != "" else "COCA_THANKS", 8.0)
	told.emit(clue)


## Whether any cop is still waiting for a number (she only calls while someone is).
func has_waiting() -> bool:
	return tickets.values().any(func(n: int) -> bool: return n > serving)


## Online: who she's serving, the last ticket and whether she told (NpcSync).
func net_state() -> Variant:
	return [serving, next_ticket, served]


func apply_net_state(state: Variant) -> void:
	if serving != state[0]:
		serving = state[0]
		_show_board()
	next_ticket = state[1]
	served = state[2]


func _physics_process(delta: float) -> void:
	_since_idle += delta
	if has_waiting():
		_since_call += delta
		if _since_call >= CALL_EVERY:
			call_next()
		return
	_since_call = 0.0
	if _since_idle < IDLE_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= TALK_RANGE:
			_since_idle = 0.0
			_say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return


func _counter() -> Vector3:
	var place := get_parent() as Node3D
	return place.to_global(counter_spot) if place else counter_spot


func _show_board() -> void:
	_board.text = "%d" % serving


func _say(key: String, seconds := 3.0) -> void:
	_since_idle = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
