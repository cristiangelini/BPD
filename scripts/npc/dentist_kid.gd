class_name DentistKid
extends StaticBody3D

## Lucho (docs/diseno/allanamiento-dentista.md, "El chismoso"), a 10-year-old with braces who has been in the dental
## office's waiting room for hours. He only talks to a cop who brings him a candy from the reception's jar (the doctor
## forbids them): E with the candy in hand and he eats it and tells what he saw the doctor hide (`clue`, set by the
## story). Once per case; another candy only gets a thank you. Every number here is (propuesta).

## A cop brought him a candy and he told what he saw: the checklist line, already translated.
signal told(text: String)
## He got a candy, where he is (the doctor minds it if he sees it).
signal ate_candy(at: Vector3)

const MODEL := preload("res://assets/models/npc_lucho.glb")
const CANDY_GROUP := "dentist_candy"
const IDLE_LINES := ["LUCHO_IDLE_1", "LUCHO_IDLE_2", "LUCHO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
var has_told := false
var candies := 0
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.1
	shape.shape = capsule
	shape.position.y = 0.55
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.5, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## The candy in `cop`'s hands, if any.
static func candy_of(cop: Cop) -> Grabbable:
	var held: Grabbable = cop.get_node("Grabber").held
	return held if held and held.is_in_group(CANDY_GROUP) else null


func prompt_key(cop: Cop) -> String:
	return "PROMPT_LUCHO_CANDY" if candy_of(cop) else "PROMPT_LUCHO"


## E on him: with a candy he eats it (and tells, the first time); without one he asks for it.
func use(cop: Cop) -> void:
	var candy := candy_of(cop)
	if not candy:
		_say("LUCHO_AGAIN" if has_told else "LUCHO_WANTS_CANDY", 4.0)
		return
	cop.get_node("Grabber").release()
	candy.hide()
	# Every PC runs this; the host's PropSync takes the candy away from the guests.
	if multiplayer.is_server():
		candy.queue_free()
	candies += 1
	ate_candy.emit(global_position + Vector3.UP * 0.8)
	if has_told:
		_say("LUCHO_THANKS", 4.0)
		return
	has_told = true
	if clue_speech == "":
		_say("LUCHO_NOTHING", 5.0)
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
