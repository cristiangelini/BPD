class_name CostumeNiece
extends StaticBody3D

## Mimí (allanamiento-disfraces.md, "Don Fantoche y Mimí"), Don Fantoche's niece and the shop's gossip. She plays hide
## and seek dressed as a chicken mannequin, standing still among the mannequins on one of SPOTS drawn with the seed,
## and every GIGGLE_EVERY seconds a giggle slips out. Aimed at, she shows the mannequins' prompt; the cop who finds her
## (E on her, or trying to grab her) wins: she tells what she saw her uncle hide (`clue`, set by the story), once per
## cop. FOUND_STAY seconds after she's found she hides again on another spot. Every number here is (propuesta).

## A cop found her and she told what she saw: the checklist line, already translated.
signal told(text: String)
## A cop found her (the online copies and the tests follow it).
signal found(cop: Cop)

const MODEL := preload("res://assets/models/npc_mimi.glb")
const SCALE := 0.85
const GIGGLE_EVERY := 20.0
const GIGGLE_TIME := 1.5
const FOUND_STAY := 30.0

## The places she can hide (shop-local), set by the shop before she's added.
var spots: Array[Vector3] = []
## Which of `spots` she's on.
var spot := 0
## The checklist line for what she saw, and the longer thing she says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops who already found her.
var listeners := {}
var has_told := false
var _rng := RandomNumberGenerator.new()
var _giggle_left := GIGGLE_EVERY
## Counting down to hiding again after being found; 0 while hidden.
var _found_left := 0.0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4 * SCALE
	capsule.height = 1.6 * SCALE
	shape.shape = capsule
	shape.position.y = 0.8 * SCALE
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * SCALE
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.75, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## Draws her first spot with `seed` and stands her there.
func hide_first(seed: int) -> void:
	_rng.seed = hash(["mimi", seed])
	spot = _rng.randi() % spots.size()
	_stand_on(spot)


## Hidden, she passes for one more mannequin; found, she's just Mimí.
func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_MIMI" if is_found() else "PROMPT_GRAB"


func use(cop: Cop) -> void:
	find(cop)


## A cop tried to grab her: that finds her too.
func grab_tried(cop: Cop) -> void:
	find(cop)


## `cop` found her: the first time for that cop, she tells what she saw.
func find(cop: Cop) -> void:
	if listeners.has(cop):
		_say("MIMI_AGAIN", 3.0)
		return
	listeners[cop] = true
	_found_left = FOUND_STAY
	found.emit(cop)
	if clue_speech == "":
		_say("MIMI_NOTHING", 6.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func is_found() -> bool:
	return _found_left > 0.0


## What a guest's copy needs (NpcSync): whether she's found (her clock runs on the host) and on which spot.
func net_state() -> Array:
	return [is_found(), spot]


func apply_net_state(state: Array) -> void:
	_found_left = 1.0 if state[0] else 0.0
	spot = state[1]


func _physics_process(delta: float) -> void:
	if is_found():
		_found_left -= delta
		if _found_left <= 0.0:
			_hide_again()
		return
	_giggle_left -= delta
	if _giggle_left <= 0.0:
		_giggle_left = GIGGLE_EVERY
		_say("MIMI_GIGGLE", GIGGLE_TIME)


## Off to another spot, never the one she was on.
func _hide_again() -> void:
	_found_left = 0.0
	_giggle_left = GIGGLE_EVERY
	var next := (spot + 1 + _rng.randi() % (spots.size() - 1)) % spots.size()
	_stand_on(next)


func _stand_on(index: int) -> void:
	spot = index
	position = spots[index]


func _say(key: String, seconds: float) -> void:
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
