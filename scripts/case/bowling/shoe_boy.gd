class_name ShoeBoy
extends StaticBody3D

## Pipo, the shoe boy of the bowling alley and its gossip (allanamiento-bolera.md, "Don Chuza y Pipo"). He stands
## behind the shoe counter spraying deodorant into the shoes. E on him gives a cop a pair of bowling shoes (with them
## the cop slides less on the waxed lanes); E again gives them back, and Pipo, happy that somebody returns something,
## tells where he saw Don Chuza hide something (`clue`, set by the story). Once per cop. Every number here is
## (propuesta).

## A cop gave the shoes back and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_pipo.glb")
const SCALE := 0.75
const IDLE_LINES := ["PIPO_IDLE_1", "PIPO_IDLE_2", "PIPO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0
const SAY_TIME := 4.0

## The checklist line for what he saw and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops wearing a pair of his shoes now (which pair he handed out, counting from 0), the ones who already gave a
## pair back, and how many pairs he handed out.
var wearing := {}
var returned := {}
var has_told := false
var pairs_out := 0
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.2
	shape.shape = capsule
	shape.position.y = 0.6
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * SCALE
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.5, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	return "PROMPT_PIPO_RETURN" if wears(cop) else "PROMPT_PIPO_SHOES"


## E on him: a pair of shoes, or the pair back and, the first time, what he saw.
func use(cop: Cop) -> void:
	if not wears(cop):
		wearing[cop] = pairs_out
		pairs_out += 1
		say("PIPO_SHOES")
		cop.show_hint("HINT_BOWL_SHOES_ON")
		return
	wearing.erase(cop)
	cop.show_hint("HINT_BOWL_SHOES_OFF")
	if returned.has(cop):
		say("PIPO_THANKS")
		return
	returned[cop] = true
	if clue_speech == "":
		say("PIPO_NOTHING", 6.0)
		return
	say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


## Whether `cop` has a pair of his shoes on.
func wears(cop: Cop) -> bool:
	return wearing.has(cop)


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	_since_idle += delta
	if _since_idle < IDLE_EVERY or _bubble.visible:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		if (node as Node3D).global_position.distance_to(global_position) < TALK_RANGE:
			_since_idle = 0.0
			say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return
