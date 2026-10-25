class_name BankManager
extends CharacterBody3D

## Mr. Moneda, the bank's manager (robo-banco-gerente.md, step 1, decision 124): in every bank robbery he waits on the
## sidewalk by his car, in pajamas and slippers, pacing back and forth, rubbing his arms and complaining out loud. E on
## him gets the back door's key: he hands it to the first cop who talks to him (Cop.has_key, the same flag as the
## grandpa's pots), and the back door (FrontDoor) opens with it from outside. Later he only complains. In the variant
## where he's the gang's real boss (`boss`, step 2) he looks the same at first sight.
## Every number here is (propuesta).

signal key_given(cop: Cop)

const MODEL := preload("res://assets/models/npc_gerente.glb")
## He paces this fast (m/s) between his two spots, and stands this long at each end (s).
const SPEED := 0.6
const PAUSE := 3.0
const REACH := 0.15
## A new complaint every this many seconds, each shown this long.
const LINE_EVERY := 9.0
const SAY_TIME := 4.0
const LINES := 4
const AGAIN_LINES := 3

## The two ends of his pacing (world positions; the level sets them before he enters the tree).
var spots: Array[Vector3] = []
## The gang's real boss (step 2).
var boss := false
var has_key := true
var next_line := 0
var _to := 1
var _pause_left := PAUSE
var _line_left := 2.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_manager")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; the manager faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	var walkie := _model.find_child("walkie", true, false) as Node3D
	if walkie:
		walkie.hide()
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	if spots.is_empty():
		spots = [global_position, global_position]


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_MANAGER"


## E: the back door's key the first time, a complaint after that.
func use(cop: Cop) -> void:
	if has_key:
		has_key = false
		cop.has_key = true
		say("MANAGER_KEY")
		cop.show_hint("HINT_BANK_BACK_KEY")
		key_given.emit(cop)
		return
	say("MANAGER_AGAIN_%d" % (next_line % AGAIN_LINES + 1))
	next_line += 1


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	_line_left -= delta
	if _line_left <= 0.0:
		_line_left = LINE_EVERY
		if _bubble_left <= 0.0:
			say("MANAGER_%d" % (next_line % LINES + 1))
			next_line += 1
	_pace(delta)


## Back and forth between his two spots, rubbing his arms (a little shiver of the model) while he stands.
func _pace(delta: float) -> void:
	if _pause_left > 0.0:
		_pause_left -= delta
		_model.rotation.z = sin(Time.get_ticks_msec() * 0.03) * 0.03
		velocity = Vector3.ZERO
		return
	_model.rotation.z = 0.0
	var to := spots[_to]
	var flat := Vector3(to.x - global_position.x, 0.0, to.z - global_position.z)
	if flat.length() <= REACH:
		_to = 1 - _to
		_pause_left = PAUSE
		velocity = Vector3.ZERO
		return
	rotation.y = atan2(-flat.x, -flat.z)
	velocity = flat.normalized() * SPEED
	velocity.y = -1.0
	move_and_slide()


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""
