class_name VipInmate
extends CharacterBody3D

## Rulo Brillantina, the city's most famous singer, a day in the prison's VIP cell (carcel-vip.md, step 2): sunglasses,
## his shiny pink jacket over the jumpsuit and his quiff, sat in his golden armchair facing the bars. He says things in
## a bubble now and then. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_rulo.glb")
const SAY_TIME := 3.5
## Sat down, the body is this much lower (in the armchair).
const SIT_DROP := 0.3
## A line of his every this many seconds while nothing else is going on.
const IDLE_EVERY := 12.0
const IDLE_LINES: Array[String] = ["VIP_RULO_IDLE_1", "VIP_RULO_IDLE_2", "VIP_RULO_IDLE_3", "VIP_RULO_IDLE_4"]

var seated := false
## A guest's copy (step 7): the host's one decides.
var follower := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _idle_left := IDLE_EVERY / 2
var _idle_line := 0


func _ready() -> void:
	add_to_group("vip_inmates")
	collision_layer = 8
	collision_mask = 1
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
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	set_seated(seated)


## Sat in his armchair (the model lower) or standing.
func set_seated(on: bool) -> void:
	seated = on
	if _model:
		_model.position.y = -SIT_DROP if on else 0.0


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
	if follower:
		return
	_idle_left -= delta
	if _idle_left <= 0.0:
		_idle_left = IDLE_EVERY
		if not _bubble.visible:
			say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
