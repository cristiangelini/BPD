class_name BankHostage
extends CharacterBody3D

## A hostage of the bank robbery (robo-banco.md, step 2, decision 102): one of the neighbors who came to the bank,
## crouched on the hall's floor in front of the counter. E on one takes them by the hand (step 4): they tell their
## complaint, a different one each time, stand up and follow that cop; out of the bank they're free, say thanks and
## go home. A robber who sees one being led out raises the alarm (BankRobber.saw_hostage). Online the host's walk and
## go free, and a guest's follow them (NpcSync, net_state). Every number here is (propuesta).

signal freed_now(hostage: BankHostage)

const LOOKS: Array[String] = ["vecina", "clienta", "cliente", "senora", "abuelo", "abuela", "politico", "repartidor",
	"heladero", "periodista"]
const SCALES := {"abuelo": 0.82, "abuela": 0.8}
## Crouched on the floor: the model squashed this much.
const CROUCH := 0.82
const LINES := 8
const SAY_TIME := 4.0
## They walk this fast (m/s), this far behind the cop's hand.
const SPEED := 1.8
const KEEP_AWAY := 1.2

@export var look := "vecina"
var next_line := 0
## The cop leading them by the hand, if any.
var led_by: Cop
var freed := false
## Whether a world position is out of the bank (the level sets it; nowhere is, by default).
var is_out: Callable = func(_at: Vector3) -> bool: return false
var _model: Node3D
var _size := 1.0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_hostages")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.3
	shape.shape = capsule
	shape.position.y = 0.65
	add_child(shape)
	_model = load("res://assets/models/npc_%s.glb" % look).instantiate()
	_size = SCALES.get(look, 1.0)
	_model.scale = Vector3(_size, _size * CROUCH, _size)
	# The models face +Z; the hostage faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.6, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if freed:
		return ""
	return "PROMPT_LET_GO_HOSTAGE" if led_by == cop else "PROMPT_LEAD_HOSTAGE"


## E: takes them by the hand (they tell their complaint and stand up), or lets go (they crouch where they are).
func use(cop: Cop) -> void:
	if freed:
		return
	if led_by == cop:
		led_by = null
		_model.scale.y = _size * CROUCH
		return
	led_by = cop
	_model.scale.y = _size
	say("HOSTAGE_%d" % (next_line % LINES + 1))
	next_line += 1


func _physics_process(delta: float) -> void:
	if freed or not led_by:
		return
	if is_out.call(global_position):
		free_hostage()
		return
	var to := led_by.global_position - global_position
	to.y = 0.0
	var wish := to.normalized() * SPEED if to.length() > KEEP_AWAY else Vector3.ZERO
	if wish.length() > 0.05:
		look_at(global_position + wish, Vector3.UP)
	velocity = Vector3(wish.x, 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta, wish.z)
	move_and_slide()


## Out of the bank: thanks, and home (gone once the line's said).
func free_hostage() -> void:
	freed = true
	led_by = null
	collision_layer = 0
	say("HOSTAGE_FREE")
	freed_now.emit(self)


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What a guest's copy needs besides where they are and what they say (NpcSync): free, standing up and still here.
func net_state() -> Array:
	return [freed, is_equal_approx(_model.scale.y, _size), visible]


func apply_net_state(state: Variant) -> void:
	if state[0] and not freed:
		freed = true
		led_by = null
		collision_layer = 0
		freed_now.emit(self)
	_model.scale.y = _size if state[1] else _size * CROUCH
	visible = state[2]


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
			if freed:
				hide()
