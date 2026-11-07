class_name FurnitureAssembler
extends StaticBody3D

## Tablita (docs/diseno/allanamiento-muebleria.md, "Tablita"), the furniture store's assembler and its gossip. He's in
## the middle of the shop putting a bookcase together with the manual upside down, and only talks to whoever holds its
## shelf up for him (BookcaseShelf): then he tells what he saw Don Cajón hide (`clue`, set by the story). Once per
## cop. Every number here is (propuesta).

## A cop held the shelf up and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_tablita.glb")
const IDLE_LINES := ["TABLITA_IDLE_1", "TABLITA_IDLE_2", "TABLITA_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops he already talked to.
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
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## A cop picks the shelf up: he asks them to hold it still, or tells one he already talked to that he has nothing new.
func holding(cop: Cop) -> void:
	_say("TABLITA_AGAIN" if listeners.has(cop) else "TABLITA_HOLD", 4.0)


## The shelf slipped before he could screw it in.
func dropped() -> void:
	_say("TABLITA_DROPPED", 3.0)


## The shelf is in: he tells `cop` what he saw.
func held_by(cop: Cop) -> void:
	if listeners.has(cop):
		return
	listeners[cop] = true
	if clue_speech == "":
		_say("TABLITA_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
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
