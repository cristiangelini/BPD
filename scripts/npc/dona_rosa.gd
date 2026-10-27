class_name DonaRosa
extends Node3D

## Doña Rosa (docs/diseno/allanamiento-radio.md, "Doña Rosa"), the station's most loyal listener and its gossip, only
## on the phone: she calls the reception every CALL_EVERY seconds. A cop who answers and stays by the phone for
## LISTEN_SECONDS hears, between her chatter, where don Volumen let slip on air that he keeps something (`clue`, set by
## the story). A cop who walks off sooner gets "¡Qué maleducado, como el locutor!" and waits for her next call. Once per
## cop. She sits at the phone, `phone`, set by the radio. Every number here is (propuesta).

## A cop heard her out and she told what she heard: the checklist line, already translated.
signal told(text: String)

const CALL_EVERY := 40.0
## How long her call rings before she hangs up, and how long a cop must listen.
const RING_FOR := 10.0
const LISTEN_SECONDS := 6.0
## A cop farther than this from the phone hung up on her.
const LISTEN_RANGE := 2.0
const CHAT_LINES := ["ROSA_CHAT_1", "ROSA_CHAT_2", "ROSA_CHAT_3"]

## The checklist line for what she heard, and the longer thing she tells (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The phone she calls (set by the radio before she's added).
var phone: DeskPhone
## The cops she already told.
var listeners := {}
var has_told := false
## Whether the phone is ringing with her call, and the cop listening to her (null when nobody is).
var calling := false
var listener: Cop
var listened_for := 0.0
## Seconds until her next call, and left of the current ring.
var next_call := CALL_EVERY
var _ring_left := 0.0
var _bubble: Label3D


func _ready() -> void:
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 0.7, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 34
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## Rings the phone with her call, unless it's already ringing.
func call_now() -> void:
	next_call = CALL_EVERY
	if phone.is_ringing() or listener:
		return
	calling = true
	_ring_left = RING_FOR
	phone.ring()


## A cop answered her call: she starts talking.
func answer(cop: Cop) -> void:
	calling = false
	listener = cop
	listened_for = 0.0
	_say(CHAT_LINES[0], LISTEN_SECONDS)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if listener:
		_listen(delta)
		return
	if calling:
		_ring_left -= delta
		if _ring_left <= 0.0:
			calling = false
			phone.get_node("Ring").hide()
		return
	next_call -= delta
	if next_call <= 0.0:
		call_now()


## The cop on the line: a chatter line every few seconds, until they walk off or hear her out.
func _listen(delta: float) -> void:
	if listener.global_position.distance_to(phone.global_position) > LISTEN_RANGE:
		listener = null
		_say("ROSA_RUDE", 3.0)
		return
	var part := LISTEN_SECONDS / CHAT_LINES.size()
	var before := int(listened_for / part)
	listened_for += delta
	var now := int(listened_for / part)
	if listened_for >= LISTEN_SECONDS:
		_tell(listener)
		listener = null
	elif now != before and now < CHAT_LINES.size():
		_say(CHAT_LINES[now], part)


## She tells what she heard, once per cop.
func _tell(cop: Cop) -> void:
	if listeners.has(cop):
		_say("ROSA_AGAIN", 4.0)
		return
	listeners[cop] = true
	if clue_speech == "":
		_say("ROSA_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func _say(key: String, seconds := 3.0) -> void:
	_bubble.text = key
	_bubble.show()
	var said_now := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said_now:
			_bubble.hide())
