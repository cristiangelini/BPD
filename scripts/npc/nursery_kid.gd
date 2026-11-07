class_name NurseryKid
extends StaticBody3D

## Brotecito (docs/diseno/allanamiento-vivero.md, "Brotecito, el chico del riego"), the nursery's watering kid and its
## gossip. He waters the greenhouse all day and his can is always empty: he only talks to whoever brings it to him full
## from the tap without spilling it. Then he waters with it and tells what he saw Doña Hortensia hide (`clue`, set by
## the story). Once per cop. E on him only gets him asking for water. Every number here is (propuesta).

## A cop brought him the full can and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_brotecito.glb")
## He's a kid: his model is scaled down.
const SCALE := 0.75
## A full can this close to him (m) is his.
const GIVE_RANGE := 1.5
const IDLE_LINES := ["BROTECITO_IDLE_1", "BROTECITO_IDLE_2", "BROTECITO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops he already talked to.
var listeners := {}
var has_told := false
var cans_brought := 0
var _since_idle := 0.0
var _idle_line := 0
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.2
	shape.shape = capsule
	shape.position.y = 0.6
	add_child(shape)
	var look: Node3D = MODEL.instantiate()
	look.scale = Vector3.ONE * SCALE
	add_child(look)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.7, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BROTECITO"


## E on him: he asks for water.
func use(cop: Cop) -> void:
	_say("BROTECITO_AGAIN" if listeners.has(cop) else "BROTECITO_ASK", 4.0)


## A full can reached him: he waters with it and, the first time for the cop who brought it, tells what he saw.
func take(can: WateringCan) -> void:
	if not can.full:
		return
	can.pour()
	cans_brought += 1
	var cops := can.handling_cops(3.0)
	var cop: Cop = cops[0] if not cops.is_empty() else null
	if cop == null or listeners.has(cop):
		_say("BROTECITO_THANKS", 3.0)
		return
	listeners[cop] = true
	if clue_speech == "":
		_say("BROTECITO_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func _physics_process(delta: float) -> void:
	for node in get_tree().get_nodes_in_group("watering_cans"):
		var can := node as WateringCan
		if can and can.full and can.global_position.distance_to(global_position + Vector3.UP * 0.6) <= GIVE_RANGE:
			take(can)
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
