class_name GarageApprentice
extends StaticBody3D

## Grasita (docs/diseno/allanamiento-taller.md, "Grasita"), the garage's apprentice and its gossip. He's bent over a
## car's engine and only talks to whoever hands him the tool he asks for: E on him and he asks for one of the bench's
## tools by name; a cop who brings it into his hands hears what he saw Don Tuerca hide (`clue`, set by the story).
## Another tool gets "That's not it!" and, if it's let go, tossed back. Once per cop. Every number here is (propuesta).

## A cop brought him the right tool and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_grasita.glb")
## The tools he can ask for, by id (their models are garage_<id>, their names GARAGE_TOOL_<ID>).
const TOOLS: Array[String] = [
	"spanner_13", "adjustable_wrench", "hammer", "screwdriver", "pliers", "oil_can", "tire_iron", "flashlight",
]
## How far from him a tool counts as in his hands.
const HANDS_RADIUS := 1.1
const HANDS_HEIGHT := 0.9
## Seconds since a cop let go of a tool for it to still count as theirs.
const HANDED_SINCE := 2.0
const TOSS_SPEED := 3.0
const IDLE_LINES := ["GRASITA_IDLE_1", "GRASITA_IDLE_2", "GRASITA_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The tool he's waiting for ("" until a cop talks to him).
var wanted := ""
## The cops he already talked to.
var listeners := {}
var has_told := false
## Same seed, same asks.
var rng := RandomNumberGenerator.new()
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
	var hands := Area3D.new()
	hands.name = "Hands"
	hands.collision_layer = 0
	hands.collision_mask = 4
	var reach := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = HANDS_RADIUS
	reach.shape = sphere
	reach.position.y = HANDS_HEIGHT
	hands.add_child(reach)
	add_child(hands)
	hands.body_entered.connect(_on_handed)
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


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GRASITA"


## E on him: he asks for a tool (the same one until it comes), or, for a cop he already talked to, nothing new.
func use(cop: Cop) -> void:
	if listeners.has(cop):
		_say("GRASITA_AGAIN", 3.0)
		return
	if wanted == "":
		wanted = TOOLS[rng.randi_range(0, TOOLS.size() - 1)]
	_say(tr("GRASITA_ASK") % tr("GARAGE_TOOL_" + wanted.to_upper()), 5.0)


## A tool brought into his hands: the right one and he talks to whoever brought it; another and he sends it back.
func hand(tool: Grabbable, cop: Cop) -> void:
	if wanted == "" or listeners.has(cop):
		return
	if tool.get_meta("tool", "") != wanted:
		_say("GRASITA_WRONG", 3.0)
		if not tool.is_held():
			tool.linear_velocity = (cop.global_position - global_position).normalized() * TOSS_SPEED + Vector3.UP * 2.0
		return
	wanted = ""
	listeners[cop] = true
	if clue_speech == "":
		_say("GRASITA_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func _on_handed(body: Node3D) -> void:
	if not body is Grabbable or not body.has_meta("tool"):
		return
	var cops := (body as Grabbable).handling_cops(HANDED_SINCE)
	if not cops.is_empty():
		hand(body, cops[0])


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
