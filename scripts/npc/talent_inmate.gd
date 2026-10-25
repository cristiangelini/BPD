class_name TalentInmate
extends CharacterBody3D

## One of the inmates at the prison's talent show (carcel-talentos.md, step 2): sat on a bench in front of the stage
## (AUDIENCE) or up on it with a bow tie and a microphone, announcing the acts (HOST). They say things in a bubble and
## cheer with a little hop. Every number here is (propuesta).

enum Role { AUDIENCE, HOST }

const MODEL := preload("res://assets/models/npc_preso.glb")
const SAY_TIME := 3.0
## Sat down, the body is this much lower (on the bench).
const SIT_DROP := 0.35
const HOP := 0.25
const HOP_TIME := 0.15
const BOW := Color(0.8, 0.1, 0.15)
const MIC := Color(0.15, 0.15, 0.17)

var role := Role.AUDIENCE
var seated := false
## A guest's copy (step 7): the host's one decides.
var follower := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("talent_inmates")
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
	if role == Role.HOST:
		# The bow tie at the neck and the microphone in hand.
		_model.add_child(CopTool.piece(CopTool.box(Vector3(0.22, 0.09, 0.04)), BOW, Vector3(0, 1.1, 0.28)))
		_model.add_child(CopTool.piece(CopTool.cylinder(0.025, 0.22), MIC, Vector3(0.36, 0.85, 0.3)))
		_model.add_child(CopTool.piece(CopTool.cylinder(0.045, 0.06), MIC, Vector3(0.36, 0.98, 0.3)))
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


## On the bench (lower) or standing.
func set_seated(on: bool) -> void:
	seated = on
	if _model:
		_model.position.y = -SIT_DROP if on else 0.0


## Turned to look at `at` (world space).
func face(at: Vector3) -> void:
	var away := global_position - (at - global_position)
	away.y = global_position.y
	if away.distance_to(global_position) > 0.01:
		look_at(away, Vector3.UP)


## A little hop where they are (clapping an act).
func cheer() -> void:
	var rest := -SIT_DROP if seated else 0.0
	var hop := create_tween()
	hop.tween_property(_model, "position:y", rest + HOP, HOP_TIME)
	hop.tween_property(_model, "position:y", rest, HOP_TIME)


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
