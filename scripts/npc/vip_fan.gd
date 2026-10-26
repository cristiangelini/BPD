class_name VipFan
extends StaticBody3D

## One of Rulo Brillantina's fans on the sidewalk by the prison's gate (carcel-vip.md, step 2): a pink t-shirt and a
## sign on a stick, hopping and shouting his name. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_fan.glb")
const CHANTS: Array[String] = ["VIP_FAN_CHANT_1", "VIP_FAN_CHANT_2", "VIP_FAN_CHANT_3"]
## A chant every this many seconds, each fan offset by `beat` so they don't all shout at once.
const CHANT_EVERY := 6.0
const CHANT_TIME := 1.8
const HOP := 0.2
const HOP_TIME := 0.18

## Which beat of the chant this fan is on (0 to 5).
var beat := 0
var _model: Node3D
var _bubble: Label3D
var _left := 0.0
var _shouting := 0.0
var _chant := 0


func _ready() -> void:
	add_to_group("vip_fans")
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.3 + 0.35 * (beat % 2), 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 48
	_bubble.modulate = Color(1.0, 0.6, 0.85)
	_bubble.hide()
	add_child(_bubble)
	_left = 0.5 + beat * CHANT_EVERY / 6.0
	_chant = beat


func shouted() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _shouting > 0.0:
		_shouting -= delta
		if _shouting <= 0.0:
			_bubble.hide()
	_left -= delta
	if _left > 0.0:
		return
	_left = CHANT_EVERY
	_bubble.text = CHANTS[_chant % CHANTS.size()]
	_chant += 1
	_bubble.show()
	_shouting = CHANT_TIME
	var hop := _model.create_tween()
	for i in 2:
		hop.tween_property(_model, "position:y", HOP, HOP_TIME).set_trans(Tween.TRANS_SINE)
		hop.tween_property(_model, "position:y", 0.0, HOP_TIME).set_trans(Tween.TRANS_SINE)
