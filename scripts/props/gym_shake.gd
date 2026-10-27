class_name GymShake
extends StaticBody3D

## A cup of the reception's green shake, with a four-leaf clover sticker (allanamiento-gimnasio.md, "Los batidos de la
## suerte"): E drinks it (SIP seconds with full hands, Cop.eat) and the cop says out loud what they're thinking for
## THINK_TIME seconds, a different line each time. Every number here is (propuesta).

signal drunk(cop: Cop)

const MODEL := preload("res://assets/models/gym_shake_cup.glb")
const SIZE := Vector3(0.1, 0.27, 0.1)
const SIP := 2.0
const THINK_TIME := 5.0
const THOUGHTS := 8
const THOUGHT_COLOR := Color(0.6, 1.0, 0.6)

var sips := 0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SHAKE"


func use(cop: Cop) -> void:
	cop.eat(SIP)
	var thought := Label3D.new()
	thought.name = "Thought"
	thought.text = "GYM_THOUGHT_%d" % (sips % THOUGHTS)
	thought.font_size = 40
	thought.pixel_size = 0.005
	thought.outline_size = 10
	thought.modulate = THOUGHT_COLOR
	thought.width = 600.0
	thought.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	thought.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	thought.position = Vector3(0, 2.1, 0)
	cop.add_child(thought)
	get_tree().create_timer(THINK_TIME).timeout.connect(thought.queue_free)
	sips += 1
	drunk.emit(cop)
