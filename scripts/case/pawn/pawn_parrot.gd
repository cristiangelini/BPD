class_name PawnParrot
extends StaticBody3D

## Chicharra (allanamiento-empenos.md, "Don Regateo y Chicharra"), the pawn shop's parrot in his cage by the counter,
## and its gossip. He repeats what he heard at night, but only for a cookie from the jar: E on the cage with one, he
## eats it and repeats what Don Regateo said while hiding something (`clue`, set by the story), once per cop. Every
## SQUAWK_EVERY seconds he squawks something he heard by day. Every number here is (propuesta).

## A cop fed him and he told what he heard: the checklist line, already translated.
signal told(text: String)
## A cop fed him (the online copies and the tests follow it).
signal fed(cop: Cop)

const SIZE := Vector3(0.5, 0.8, 0.5)
const SQUAWK_EVERY := 20.0
const SQUAWK_TIME := 2.0
const SQUAWKS := ["PARROT_SQUAWK_1", "PARROT_SQUAWK_2", "PARROT_SQUAWK_3"]

## The jar the cookies come from (set by the shop).
var jar: CookieJar
## The checklist line for what he heard, and what he repeats (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops who already fed him.
var listeners := {}
var has_told := false
var _squawk_left := SQUAWK_EVERY
var _squawk := 0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = -SIZE.y / 2
	add_child(shape)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 0.25, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if listeners.has(cop):
		return ""
	return "PROMPT_PAWN_PARROT_FEED" if jar and jar.has_cookie(cop) else "PROMPT_PAWN_PARROT"


func use(cop: Cop) -> void:
	if listeners.has(cop):
		return
	if not jar or not jar.has_cookie(cop):
		_say("PARROT_WANTS_COOKIE", 3.0)
		return
	jar.eat(cop)
	listeners[cop] = true
	fed.emit(cop)
	if clue_speech == "":
		_say("PARROT_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	_squawk_left -= delta
	if _squawk_left <= 0.0:
		_squawk_left = SQUAWK_EVERY
		if not _bubble.visible:
			_say(SQUAWKS[_squawk % SQUAWKS.size()], SQUAWK_TIME)
			_squawk += 1


func _say(key: String, seconds: float) -> void:
	_bubble.text = key
	_bubble.show()
	var line := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == line:
			_bubble.hide())
