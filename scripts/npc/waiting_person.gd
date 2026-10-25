class_name WaitingPerson
extends StaticBody3D

## Someone in the station's waiting room in the fire drill jailbreak (docs/diseno/fuga-simulacro.md, step 1): it's
## daytime, and people came to report something, complain or deliver a pizza. They stand or wait by the benches and
## grumble now and then. The drill (step 2) walks them out. Every number here is (propuesta).

## Who can be there, by model.
const KINDS: Array[String] = ["senora", "repartidor", "abuelo", "abuela", "vecina", "cliente", "clienta",
	"periodista", "portero", "abogado", "panadera", "heladero"]
const CHAT_MIN := 12.0
const CHAT_MAX := 30.0
const LINES := 10
const BUBBLE_TIME := 4.0
const RADIUS := 0.35
const HEIGHT := 1.6

var kind := "senora"
var _rng := RandomNumberGenerator.new()
var _chat_left := 0.0
var _bubble: Label3D
var _bubble_left := 0.0


## Who this one is, and when they first say something.
func set_up(person_kind: String, person_seed: int) -> void:
	kind = person_kind
	_rng.seed = person_seed
	_chat_left = _rng.randf_range(CHAT_MIN, CHAT_MAX)


func _ready() -> void:
	add_to_group("waiting_people")
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = RADIUS
	capsule.height = HEIGHT
	shape.shape = capsule
	shape.position.y = HEIGHT / 2
	add_child(shape)
	add_child(load("res://assets/models/npc_%s.glb" % kind).instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.position.y = 2.0
	_bubble.font_size = 40
	_bubble.outline_size = 10
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.visible = false
	add_child(_bubble)


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		_bubble.visible = _bubble_left > 0.0
	_chat_left -= delta
	if _chat_left <= 0.0:
		_chat_left = _rng.randf_range(CHAT_MIN, CHAT_MAX)
		say("WAITING_LINE_%d" % _rng.randi_range(0, LINES - 1))


func say(key: String) -> void:
	_bubble.text = key
	_bubble.visible = true
	_bubble_left = BUBBLE_TIME


## Online: guests make the same people from the same seed; NpcSync only moves them and their bubble.
func net_state() -> Variant:
	return kind


func apply_net_state(_state: Variant) -> void:
	pass
